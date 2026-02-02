# Prompt Staging Area

> **Navigation**: [Process](./README.md) | [Documentation Root](../README.md)

This file is a staging area for complex human-to-AI instructions. The human pilot drafts and refines prompts here before execution.

---

# Current Prompt

## Comments

Re: NIF
Yes, reserve `catch_unwind` for truly exceptional circumstances.
Please document this point if undocumented.

We will proceed to migrating to GitHub Issues, and then we will review the process state.
Please comment on the following.

- Does integration with GitHub Projects make sense?
- Does Linear or Notion integration have clear advantages for agentic workflow?

Once GitHub/project management integration is done, we will close the Process Definition macro-milestone and begin V0.1 Foundation.

Birdeye + Raydium confirmed as initial strategy.
Does DEX Screener have a free API that could be worth leveraging?
Is there an obvious API for tracking the BTC price, and TradFi trading metrics (price of oil, futures, etc)?

## Objectives

Migrate to markdown-based objective management GitHub Issues.

- Move completed historal objectives to something like "V0.0 Historical Summary" and mark as complete.
- Create issues for identified V0.0 and V0.1 milestones.
- Hold off on V0.2 to V0.6 milestone definition.

You mentioned the following migration approach. It is acceptable.

```sh
# Create labels for versions and types
gh label create "V0.0" --description "Phase 0: Process Definition"
gh label create "V0.1" --description "Phase 1: Foundation"
gh label create "type:task" --description "Implementation task"
gh label create "type:decision" --description "Decision required"

# Create GitHub Milestones
gh api repos/:owner/:repo/milestones -f title="V0.1 Foundation" -f description="Phase 1 deliverables"

# Create issue from PROMPT_BACKLOG item
gh issue create --title "B5: Project management integration" --body "Consider integration with issue           tracking" --label "type:suggestion"
 ```

Make sure the GitHub Issues-based process replaces the markdown based process in the knowledge graph.

Document that `gh` must be installed in the top level README.md.
Check that `gh` and `git` are installed with the setup script.
Have the setup script print a message that asks the user to review and consider installing:
`docs/reference/MASTER_CLAUDE_MD_REFERENCE.md`

## Context

Markdown-based project management is clunky.

## Constraints

Preserve and depreciate existing markdown files for now.

## Success Criteria

- V0.0 Historical Summary tasks add and marked as complete.
- V0.0 Outstanding milestones added.
- V0.1 Outstanding milestones added.

## Notes

(no notes)
