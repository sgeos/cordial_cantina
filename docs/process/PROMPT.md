# Prompt Staging Area

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is a staging area for complex human-to-AI instructions. The human pilot drafts and refines prompts here before execution.

---

# Current Prompt

## Comments

Process definition is incomplete.
We are still working on the github-related processes.
The macro-milestone will be complete after CI is passing and no other process TODOs remain.
I am considering migrating to Github Issues if this can be arrange agentically using command line tools.
Please comment on this in your reverse prompt.

Is liveview giving any visual feedback at all? What URL should I be looking at?

## Objectives

### Resolve CI Failure

Rust CI failed on GitHub.
The failing step was: Run clippy
See:
https://github.com/sgeos/cordial_cantina/actions/runs/21589349101/job/62205275680

Please resolve or give instructions for human pilot in you reverse prompt.

### Add CI Status Badge to tople level README.md

I am pretty sure this can be done before the first passing CI run.

### NIF Testing

- Add an Elixir test that explicitly calls `CordialCantina.Nif.nop()` to verify NIF loading in  the test suite.
- Add the NIF build to CI.
- Add a test to the NIF stub so that `cargo test` is nominally meaningful.

### LiveView real-time

Add Phoenix PubSub for real-time updates. Push a visual indicator, like the datetime for manual verification.

### Remove Mention of Orbital Market Maker

The product name "Orbital Market Maker" was suggested by another LLM session.
The product/service name is Cordial Cantina. Joltshark is the name of the portable, general-purpose financial library.
Documentation should be updated to reflect name "Cordial Cantina".

If I were to do this manually, I would use `grep` to search for files containing the word "orbital" (case insensitive).
Then I would review each file.
Note that only the incorrect Orbital Market Maker product/service name should be removed, not references to orbital mechanics as a physical technique.

---

## Context

CI still failing.
Reasonable reverse prompt suggestions.
I want to be able to manually check LiveView setup on a running server.
Documentation cleanup is low priority and non-block, but immediately obvious and trivial to fix.

## Constraints

During documentation cleanup, retain mention of orbital mechanics as a physic concept.

## Success Criteria

CI passes on GitHub.
NIF testing (Rust and Elixir) implemented and passing.
NIF added to CI.
Liveview PubSub implemented with visual feedback on live server.
No mention of Orbital Market Maker product name.

## Notes

I want to know the URL/route to the page where LiveView updates are being pushing to confirm functionality.
