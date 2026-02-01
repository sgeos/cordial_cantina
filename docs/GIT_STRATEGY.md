# GIT_STRATEGY.md

This document codifies the git strategy for Cordial Cantina. The strategy is designed for trunk-based development with multiple concurrent human/AI-agent pairs.

## Document Status

**Created**: 2026-02-01
**Purpose**: Version control conventions for agentic development
**Scope**: All contributors (human and AI-agent)

---

## Trunk-Based Development

This project uses trunk-based development. All work flows through short-lived feature branches that merge into `main`.

**Rationale**: Trunk-based development is well-suited for agentic-AI development loops because:
- Short-lived branches reduce merge conflicts between concurrent agent pairs
- Linear history makes the codebase "story" readable for AI agents
- Frequent integration surfaces issues early
- Small, atomic changes are easier to review and revert

---

## Branch Strategy

### Main Branch

The `main` branch is the single source of truth.

- Always deployable (or at minimum, always compiles and passes tests)
- Protected from direct pushes
- All changes arrive via pull request with rebase

### Feature Branches

All development occurs on feature branches.

**Naming convention**: `<scope>/<short-description>`

| Scope | Purpose | Example |
|-------|---------|---------|
| `feat` | New functionality | `feat/mnesia-table-init` |
| `fix` | Bug fixes | `fix/rpc-timeout-handling` |
| `docs` | Documentation only | `docs/supervision-tree` |
| `refactor` | Code restructuring | `refactor/extract-offload-worker` |
| `test` | Test additions or fixes | `test/position-manager-recovery` |
| `chore` | Maintenance tasks | `chore/update-dependencies` |

**Lifespan**: Feature branches should not live longer than 24 hours. If work exceeds this window:
- Break the work into smaller increments
- Merge partial progress behind a feature flag if necessary
- Communicate blockers to other agent pairs

### Creating a Feature Branch

```bash
git checkout main
git pull --rebase origin main
git checkout -b feat/my-feature
```

---

## Linear History

**Enforce rebase, not merge.**

Linear history keeps the commit log readable for AI agents parsing project history. Merge commits obscure the narrative of changes.

### Integrating Upstream Changes

When `main` has advanced while working on a feature branch:

```bash
git fetch origin
git rebase origin/main
```

Resolve any conflicts, then continue:

```bash
git rebase --continue
```

### Pull Request Merge Strategy

Pull requests merge via **rebase and fast-forward** (no merge commits).

Repository settings should enforce:
- Require linear history
- Require rebase before merge
- Require passing status checks

---

## Commit Conventions

### Commit Message Format

```
<scope>: <imperative summary>

<optional body explaining why, not what>

Co-Authored-By: <agent-identifier>
```

**Summary line**:
- Use imperative mood ("add" not "added", "fix" not "fixes")
- Keep under 72 characters
- Scope matches branch scope (feat, fix, docs, etc.)

**Body** (when needed):
- Explain motivation and context
- Reference related issues or decisions
- Note any assumptions or limitations

**Co-author**: AI agents include co-author attribution:
```
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example Commits

```
feat: add Mnesia table initialization supervisor

Initializes market_ticks and order_book_snapshots tables on application
start. Tables use ram_copies with configurable fragmentation.

See docs/SUPERVISION_TREE.md for design rationale.

Co-Authored-By: Claude <noreply@anthropic.com>
```

```
docs: draft supervision tree design

Co-Authored-By: Claude <noreply@anthropic.com>
```

### When to Commit

**AI agents commit after completing a prompted request.** This creates clear checkpoints in the development narrative.

Commit granularity guidelines:
- One logical change per commit
- Documentation updates may be bundled with related code changes
- Failing tests should not be committed to `main` (feature branch is acceptable during development)

---

## Workflow for Human/AI-Agent Pairs

### Starting Work

1. Pull latest `main`
2. Create feature branch with appropriate scope
3. Communicate intent (branch name serves as declaration)

### During Development

1. Make changes in response to prompts
2. Commit after each completed request
3. Rebase on `main` if working for extended period

### Completing Work

1. Ensure all tests pass (`mix precommit`)
2. Rebase on latest `main`
3. Push feature branch
4. Create pull request
5. After approval, rebase-merge to `main`
6. Delete feature branch

### Handling Conflicts with Other Agent Pairs

If rebase reveals conflicts:
1. Communicate with the other pair if possible
2. Resolve conflicts preserving both intents
3. Re-run tests after resolution
4. Document non-obvious resolution decisions in commit message

---

## Future: Git Worktrees

Git worktrees allow multiple working directories sharing the same repository history. This enables:
- Each agent pair has an isolated "sandbox" folder
- No risk of uncommitted changes colliding
- Parallel work on different features without branch switching

**Not yet implemented.** When multiple agent pairs are active, introduce worktrees:

```bash
# Create worktree for agent pair
git worktree add ../cordial_cantina-agent-2 -b feat/agent-2-feature

# Remove worktree when done
git worktree remove ../cordial_cantina-agent-2
```

Worktree conventions (when adopted):
- Worktree directory naming: `<repo>-<agent-identifier>`
- Each worktree operates on its own feature branch
- Worktrees are ephemeral and removed after branch merge

---

## Repository Structure

```
cordial_cantina/           # Git repository root
├── .git/                  # Git data (shared by all worktrees)
├── cordial_cantina/       # Elixir/Phoenix application
├── joltshark/             # Rust library
├── docs/                  # Documentation
├── CLAUDE.md              # AI agent instructions
└── README.md              # Project overview
```

Both `cordial_cantina/` (Elixir) and `joltshark/` (Rust) are tracked in the same repository. Commits may span both subprojects when changes are logically related.

---

## Pre-Push Checklist

Before pushing a feature branch for review:

- [ ] `mix precommit` passes (compile, format, test)
- [ ] `cargo test` passes (if Rust changes)
- [ ] Commit messages follow conventions
- [ ] Branch is rebased on latest `main`
- [ ] No secrets or credentials in committed files

---

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 2026-02-01 | Claude | Initial draft |
