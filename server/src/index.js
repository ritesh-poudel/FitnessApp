/**
 * Baseline insight server.
 *
 * One stateless endpoint that turns a week of readings into a short
 * plain-language explanation. It exists mainly so the Anthropic API key stays
 * on a server rather than shipping inside the iOS binary.
 *
 * The client always has a hand-written fallback, so every failure here is
 * non-fatal: we answer quickly or we answer with an error the client ignores.
 */

import express from "express";
import Anthropic from "@anthropic-ai/sdk";
import { buildPrompt } from "./prompt.js";

const PORT = process.env.PORT ?? 8787;

/** Upper bound on one generation. The client gives up at 5s, so stay under it. */
const GENERATION_TIMEOUT_MS = 4000;

/** Cache entries live this long. Judges tap the same tile repeatedly. */
const CACHE_TTL_MS = 10 * 60 * 1000;

const client = new Anthropic();
const app = express();
app.use(express.json({ limit: "16kb" }));

/** In-memory cache. A restart clears it, which is fine for a stateless service. */
const cache = new Map();

function cacheKey({ metric, series, aim, units }) {
  // Rounding keeps near-identical series on the same entry.
  const rounded = (series ?? []).map((v) => Math.round(Number(v) * 10) / 10).join(",");
  return `${metric}|${rounded}|${aim ?? ""}|${units ?? ""}`;
}

function readCache(key) {
  const hit = cache.get(key);
  if (!hit) return null;
  if (Date.now() - hit.at > CACHE_TTL_MS) {
    cache.delete(key);
    return null;
  }
  return hit.text;
}

/** Validates the request body, returning a message on failure. */
function validate(body) {
  if (!body || typeof body !== "object") return "Body must be a JSON object.";
  if (typeof body.metric !== "string" || !body.metric.trim()) {
    return "`metric` must be a non-empty string.";
  }
  if (!Array.isArray(body.series) || body.series.length === 0) {
    return "`series` must be a non-empty array of numbers.";
  }
  if (body.series.length > 60) return "`series` must hold at most 60 readings.";
  if (!body.series.every((v) => typeof v === "number" && Number.isFinite(v))) {
    return "`series` must contain only finite numbers.";
  }
  return null;
}

app.get("/health", (_req, res) => {
  res.json({ ok: true, cached: cache.size });
});

app.post("/reading", async (req, res) => {
  const problem = validate(req.body);
  if (problem) {
    return res.status(400).json({ error: problem });
  }

  const { metric, series, unit, aim, units } = req.body;
  const key = cacheKey({ metric, series, aim, units });

  const cached = readCache(key);
  if (cached) {
    return res.json({ text: cached, cached: true });
  }

  const { system, user } = buildPrompt({ metric, series, unit, aim, units });

  // Bound the wait ourselves — the client's fallback should fire fast rather
  // than the user watching a spinner.
  const abort = new AbortController();
  const timer = setTimeout(() => abort.abort(), GENERATION_TIMEOUT_MS);

  try {
    const message = await client.messages.create(
      {
        model: "claude-opus-5",
        max_tokens: 300,
        // A reading is a short, well-specified piece of writing; the lowest
        // effort keeps it fast and cheap without costing quality.
        output_config: { effort: "low" },
        system,
        messages: [{ role: "user", content: user }],
      },
      { signal: abort.signal },
    );

    // A safety refusal returns HTTP 200, so check before reading content.
    if (message.stop_reason === "refusal") {
      return res.status(422).json({ error: "Generation declined." });
    }

    const text = message.content
      .filter((block) => block.type === "text")
      .map((block) => block.text)
      .join("")
      .trim();

    if (!text) {
      return res.status(502).json({ error: "Empty generation." });
    }

    cache.set(key, { text, at: Date.now() });
    res.json({ text, cached: false });
  } catch (error) {
    const aborted = error?.name === "AbortError";
    console.error(`[reading] ${metric}: ${aborted ? "timed out" : error?.message}`);
    res.status(aborted ? 504 : 502).json({
      error: aborted ? "Generation timed out." : "Generation failed.",
    });
  } finally {
    clearTimeout(timer);
  }
});

app.listen(PORT, () => {
  console.log(`Baseline insight server listening on :${PORT}`);
});
