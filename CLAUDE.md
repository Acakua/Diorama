# Claude Code Game Studios -- Game Studio Agent Architecture

Indie game development managed through 49 coordinated Claude Code subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

## This Project: Đảo Cối Nước

A non-commercial, single-page three.js diorama: the witch Linh lives on a
floating island, with a day cycle, seasons, weather, chores and small events.
Talk to the user in Vietnamese.

- `dao-coi-nuoc.html`: the whole app (HTML, CSS and one inline ES module).
- `dao-model-1.js`, `dao-model-2.js`, `dao-model-3.js`: the VRoid AvatarSample_B
  model in base64 chunks. Licence: free to use and modify, non-commercial here;
  never set its VRM licence to CC0, never redistribute it for money, never imply
  pixiv endorsement.
- `dao-soft.js`: soft furnishings exported from Blender as glTF.
- `blender/`: Blender sources. `Xây dựng cốt truyện phù thủy.pdf`: the old story
  bible (the user dropped the long story arc; one-off events are enough).
- Run it: `python -m http.server 8765`, then open
  `http://localhost:8765/dao-coi-nuoc.html` (`.claude/launch.json`, config "dao").
- Published as a private claude.ai artifact; republish to the same URL.
- There is no code root (`src/`, `Assets/`, `Source/`): the code sits in the
  project root, so pass file paths to review skills explicitly.

## Technology Stack

- **Engine**: three.js r170 (ES module from jsdelivr via an importmap); not one
  of the engines the specialist agents cover
- **Language**: JavaScript (ES2022) and GLSL ES 3.0 shaders, inside one HTML file
- **Version Control**: Git, remote `https://github.com/Acakua/Diorama` (private),
  branch `main`; machine-only files are listed in `.gitignore`
- **Build System**: none; the page runs as-is from a static server
- **Asset Pipeline**: Blender to glTF, embedded as base64 in helper `.js` files;
  textures are drawn procedurally on canvases at load time
- **Target**: desktop browsers with WebGL2 (the owner's PC: GTX 1660 SUPER,
  180 Hz screen), 60 fps when active and 20–30 fps when idle

> **Note**: Engine-specialist agents exist for Godot, Unity, and Unreal only.
> For this project use the engine-neutral agents (lead-programmer,
> engine-programmer, technical-artist, performance-analyst,
> gameplay-programmer, qa-lead).

## Project Structure

@.claude/docs/directory-structure.md

## Engine Version Reference

No engine reference applies: three.js is not covered by `docs/engine-reference/`.
Check three.js r170 APIs against https://threejs.org/docs/ when in doubt.


## Technical Preferences

`project.yaml` at the repo root is the primary config store — engine, specialists,
naming, platform, performance, modes. Skills resolve it via `resolve_config`
(see `.claude/docs/config-resolution.md`).

`.claude/docs/technical-preferences.md` is the **legacy fallback**, read on demand
when a key is absent from `project.yaml`. It is not imported here: before
`/setup-engine` runs it is almost entirely `[TO BE CONFIGURED]` placeholders, and
after it runs `project.yaml` holds the real values.

## Coordination Rules

@.claude/docs/coordination-rules.md

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using Write/Edit tools
  (exempt: `active.md` appends, agent memory, a subagent's new file at the path
  its orchestrating skill named; see `.claude/rules/agent-memory.md`)
- Agents MUST show drafts or summaries before requesting approval
- Multi-file changes require explicit approval for the full changeset
- No commits without user instruction
- A skipped or dismissed question is not an answer: act on nothing, re-ask in
  plain text and wait
- Started outside this file's folder? Warn first: hooks, deny rules and the
  ask-first mode load only when Claude Code starts here

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for full protocol and examples.

> **First session?** If the project has no engine configured and no game concept,
> run `/start` to begin the guided onboarding flow.

## Coding Standards

@.claude/docs/coding-standards.md

## Context Management

Read `.claude/docs/context-management.md` on demand — it is a reference, not
session context. Two of its conventions are load-bearing and cited by name
elsewhere in the repo, so they are restated here rather than lost:

- **`production/session-state/active.md` is the session checkpoint.** The file is
  the memory, not the conversation. Read it first after any compaction, crash, or
  `/clear`.
- **Helpers in `.claude/scripts/` emit observations, never verdicts.** A script
  that scores or judges will eventually contradict a mode or override it cannot
  see. (Cited by `artifact-check.sh` and `adr-dep-graph.sh`.)
