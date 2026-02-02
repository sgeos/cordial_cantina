# Prompt Staging Area

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is a staging area for complex human-to-AI instructions. The human pilot drafts and refines prompts here before execution.

---

# Current Prompt

## Comments

Process definition is incomplete.
We are still working on the github-related processes.
Bi-directional prompting and document based milestones are good enough for now.

## Objective

### docs/reference/MASTER_CLAUDE_MD_REFERENCE.md Integration

I copied my `${HOME}/.claude/CLAUDE.md` file to:
`docs/reference/MASTER_CLAUDE_MD_REFERENCE.md`
Add a navigation header, and brief usage header above the body text in `docs/reference/MASTER_CLAUDE_MD_REFERENCE.md`.
The header should note:
- A) the human pilot should consider copying the body text to `${HOME}/.claude/CLAUDE.md`, and
- B) as included in the knowledge graph, AI-agents do not need be concerned with this file.
Use appropriate wording.

### Add joltshark README.md

Please draft a minimal joltshark README.md.
A proper readme will be drafted later, so it should only include the basics.

### Resolve CI Failure

Rust CI failed on GitHub with the following error.

```
Current runner version: '2.331.0'
Runner Image Provisioner
Operating System
Runner Image
GITHUB_TOKEN Permissions
Secret source: Actions
Prepare workflow directory
Prepare all required actions
Getting action download info
Error: Unable to resolve action dtolnay/rust-action, repository not found
```

Please resolve or give instructions for human pilot in you reverse prompt.

### Resolve erl_crash.dump

There is a top level erl_crash.dump
- Exclude files like this in `.gitignore`
- Investigate and resolve issue that caused what appears to be a BEAM crash.
- Delete the crash dump once the problem is resolved.
- Report the problem in your reverse prompt.

### Stub implemention

Related to the above, stub out a Phase 0 implementation of the Rust and Elixir subprojects.
- Add a `nif` Rust subproject. Pull in joltshark (repo version) and rustler as dependencies. Stub out and expose a single `nop()` function that does nothing.
- Review structure of existing structure and rework it if unsound.
- Stub out anything obvious. There should be no functionality in the stubs. Skip anything components where there is too much ambiguity to proceed with confidence. Stub out Phoenix live view.
- Build the nif and load it with Phoenix application. Call the `nop()` NIF function during startup.

## Context

`${HOME}/.claude/CLAUDE.md` inclusion suggestion was reasonable.
CI failed. This warrants resolution.
A crash dump is present. This warrants resolution.
Project stubbing is a foundation for future work, and may help resolve issues.

## Constraints

Retain existing joltshark logic. It will be revisited in the future.
The Elixir project has no substatnital functionality.

## Success Criteria

- `docs/reference/MASTER_CLAUDE_MD_REFERENCE.md` properly integrated into the knowledge graph with TOC updated.
- Minimal joltshark `README.md` added and linked to by top level `README.md`.
- CI failure resolved or instructions given for human pilot resolution.
- Issue that caused erl_crash.dump resolved so that whatever caused this particular crash is resolved is will not recur.
- Non-functional stubs add to projects to lay the groundwork for Phase 1.
- nif subproject added. NIF and `nop()` function called without issue.
- Phoenix project runs, and liveview can be viewed without issue. It is OK if there is no data for liveview to report in real time.

## Notes

(none)
