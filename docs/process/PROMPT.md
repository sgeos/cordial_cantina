# Prompt Staging Area

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is a staging area for complex human-to-AI instructions. The human pilot drafts and refines prompts here before execution.

---

# Current Prompt

## Comments

I have a master `${HOME}/.claude/CLAUDE.md` file that I want to have somewhere in this project.
The AI-agent should not be configured to read it.
It is to be included so that human pilots can consider installing it on their system.
It is also included to document the actual development environment.
Please suggest an inclusion strategy in your reverse prompt.

Record somewhere that we probably want integration with some kind of project management issue system,
so that feature impementations and fixes can be tracked above the repo level.
Keeping everything in files seems a little clunky.
Feel free to comment in your reverse prompt.

Note that our macro-milestone currently process definition.
It will be complete when we have established a good two way process.
After the process is established, we will return to clarifying requirements.

## Objective

Please integrate CI.
Please commit shared hooks, and add an environment setup script.
Please draft a top level repo README.md that documents the following.
- Links to top level documentation README.md knowledge graph.
- Documents project setup, specifically the script execution.
- Briefly explains the subprojects and top level directory structure (Elixir subproject, Rust subproject, scripts, docs).
- Links to subproject README.md files.

You had a question about verification depth.
For future code tasks, including CI, the expected verification level is a passing `mix precommit`.

You had a question about milestone naming conventions.
Milestons should use a prefix. If milestones have an unambiguous and logical code, the system is acceptable.

## Context

Reasonable reverse prompt suggestion.
README.md documents project expections and structure.

## Constraints

Strive for POSIX compliant instructions in the top level README.md.

## Success Criteria

CI tested and working.
Hooks in repo.
Setup script tested and working.
Top level README.md added and informative.

## Notes

Source code effectively consists of stubs. CI will not buy us much before real development starts, but adding it now is fine.
