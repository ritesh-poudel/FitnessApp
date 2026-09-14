/**
 * Prompt construction for plain-language metric readings.
 *
 * The voice is fixed by example rather than by adjective: the three samples
 * below are the app's own hand-written copy, and they carry the tone more
 * reliably than any description of it would.
 */

/**
 * Hand-written readings from the app, used as few-shot tone examples.
 * These are the same strings the iOS client falls back to offline, so the
 * generated and fallback voices cannot drift apart.
 */
const TONE_EXAMPLES = [
  {
    metric: "Resting heart rate",
    reading:
      "Resting heart rate drifts down as fitness builds. Anything from 55 to 70 is normal for you; a jump of 8 or more for a few days usually means you are tired or unwell.",
  },
  {
    metric: "Sleep",
    reading:
      "Your best nights start before 11pm. Six of the last seven were over seven hours, which is why your readiness is high today.",
  },
  {
    metric: "Weight",
    reading:
      "Day-to-day changes are mostly water. The two-week direction is what matters, and yours is gently down.",
  },
];

const SYSTEM = `You write one short paragraph explaining a health metric to the person it belongs to.

Voice:
- Plain words someone would use in conversation. No jargon, no coaching-speak.
- Second person. Address the reader as "you".
- Calm and factual. Never congratulate, scold, or use exclamation marks.
- No emoji, no headings, no lists, no markdown.

Content:
- Say what the number means, then what is worth noticing in the trend.
- Where it helps, give the normal range in concrete terms.
- Offer at most one small, specific, achievable suggestion — and only when the data supports it.
- Never diagnose, never name a condition, never give medical advice. If a reading looks concerning, say it is worth mentioning to a doctor, nothing more.

Length: 2 to 3 sentences. Under 55 words. Output the paragraph only.

Here are readings in exactly the voice to match:

${TONE_EXAMPLES.map((e) => `${e.metric}: ${e.reading}`).join("\n\n")}`;

/** Aim descriptions, so the reading reflects what the person is working towards. */
const AIM_CONTEXT = {
  steadyHabit: "building a steady habit — gentle targets, credit for showing up",
  trainForSomething: "training for something — harder targets, watching load and recovery",
  comeBackFromInjury: "coming back from injury — ramping slowly, wary of pushing too soon",
  keepRecords: "just keeping records — no targets or nudges wanted",
};

/**
 * Describes the series in words rather than handing over raw numbers, so the
 * model reasons about the shape of the week instead of restating a list.
 */
function describeSeries(series, unit) {
  if (!Array.isArray(series) || series.length === 0) return "No readings yet.";

  const today = series[series.length - 1];
  const earlier = series.slice(0, -1);
  const average = series.reduce((sum, v) => sum + v, 0) / series.length;
  const lowest = Math.min(...series);
  const highest = Math.max(...series);

  const round = (n) => (Number.isInteger(n) ? String(n) : n.toFixed(1));

  let direction = "flat";
  if (earlier.length > 0) {
    const earlierAverage = earlier.reduce((sum, v) => sum + v, 0) / earlier.length;
    const delta = today - earlierAverage;
    const swing = Math.abs(delta) / (earlierAverage || 1);
    if (swing > 0.05) direction = delta > 0 ? "above" : "below";
  }

  return [
    `Last 7 readings (oldest to newest): ${series.map(round).join(", ")} ${unit}.`,
    `Today: ${round(today)} ${unit}, which is ${direction} the rest of the week.`,
    `7-day average ${round(average)}, lowest ${round(lowest)}, highest ${round(highest)}.`,
  ].join(" ");
}

/** Builds the system prompt and user message for one reading. */
export function buildPrompt({ metric, series, unit, aim, units }) {
  const aimLine = AIM_CONTEXT[aim] ?? AIM_CONTEXT.steadyHabit;

  const user = [
    `Metric: ${metric}.`,
    describeSeries(series, unit ?? ""),
    `The person is ${aimLine}.`,
    units ? `They read weights in ${units}.` : null,
    "Write their reading.",
  ]
    .filter(Boolean)
    .join("\n");

  return { system: SYSTEM, user };
}
