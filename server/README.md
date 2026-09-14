# Baseline insight server

Turns a week of readings into a short plain-language explanation, in the
voice the app already uses.

The app's premise is that a number is only useful once something explains it.
`MetricSample.swift` ships a hand-written explanation for every metric; this
service generates one from the actual data instead, so the reading reflects
the week the person really had.

## Why a server at all

Key custody. The Anthropic API key must never ship inside the iOS binary,
where anyone can extract it. That is the whole reason this tier exists — there
is no database, no auth, and no session state.

## Running it

```sh
cd server
npm install
export ANTHROPIC_API_KEY=sk-ant-...
npm run dev
```

Listens on `:8787` by default; override with `PORT`.

## Endpoints

### `GET /health`

```json
{ "ok": true, "cached": 3 }
```

### `POST /reading`

```sh
curl -X POST http://localhost:8787/reading \
  -H 'Content-Type: application/json' \
  -d '{
    "metric": "Resting heart rate",
    "series": [64, 63, 62, 61, 64, 66, 62],
    "unit": "bpm",
    "aim": "steadyHabit",
    "units": "kilograms"
  }'
```

```json
{ "text": "Your resting heart rate has drifted down…", "cached": false }
```

| Field | Required | Notes |
|---|---|---|
| `metric` | yes | Display name, e.g. `"Sleep"` |
| `series` | yes | 1–60 finite numbers, oldest first |
| `unit` | no | Shown to the model, e.g. `"bpm"` |
| `aim` | no | `steadyHabit` · `trainForSomething` · `comeBackFromInjury` · `keepRecords` |
| `units` | no | `kilograms` or `pounds` |

Failure modes: `400` invalid body · `422` declined · `502` generation failed ·
`504` timed out. **The client treats every one of these as "use the written
fallback",** so none of them are user-visible.

## Design notes

- **Model** `claude-opus-5` at `effort: "low"` — a reading is short and
  well-specified, so the lowest effort keeps it fast and cheap.
- **Voice by example.** `prompt.js` few-shots three of the app's own
  hand-written readings. Those same strings are the client's offline fallback,
  so the generated and written voices cannot drift apart.
- **Series described, not dumped.** The prompt states the trend, average, and
  extremes in words, so the model explains the shape rather than restating a list.
- **4s server timeout, 5s client timeout.** The fallback is already on screen;
  a slow answer is worse than no answer.
- **In-memory cache**, 10 minutes, keyed on metric + rounded series. Reopening
  the same tile does not re-generate.
- **Safety.** The prompt forbids diagnosis and advice. `stop_reason: "refusal"`
  is checked before reading content, since a decline still returns HTTP 200.

## Deploying

Any Node host works — Render, Railway, Fly. Set `ANTHROPIC_API_KEY` in the
environment and run `npm start`. Point the app at it with `INSIGHT_BASE_URL`.
