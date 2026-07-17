---
name: git-workflow
description: Professional git branching and commit workflow for solo devs and freelance client projects. Use this skill whenever the user asks to commit, push, create a branch, open a PR, start a new feature/fix, initialize a git repo, or says things like "push this", "commit this", "start working on X", "I'm done with this feature", or "set up git for this project". Also use it whenever code changes are about to be committed or pushed, even if the user didn't explicitly ask about git — always check whether the current branch is main/master before committing, and if so, create a proper feature branch first instead of committing directly to main.
---

# Git Workflow

A lightweight branch-per-feature workflow for solo/freelance projects (client sites, portfolio pieces, small apps). Goal: keep `main` always clean and deployable, get PR/review habits even when working alone, and produce a readable git history.

## Core rule

**Never commit directly to `main`.** Before running `git add`/`git commit`, always check the current branch:

```bash
git branch --show-current
```

If it's `main` or `master`, stop and create a feature branch first (see below) before committing anything.

## Branch naming

```
feature/<short-description>   # new feature or component
fix/<short-description>       # bug fix
chore/<short-description>     # config, deps, tooling, setup
refactor/<short-description>  # code change, no behavior change
style/<short-description>     # CSS/formatting only, no logic change
docs/<short-description>      # README, comments, docs
```

Keep `<short-description>` 2-4 words, kebab-case. e.g. `feature/hero-video-bg`, `fix/rtl-arrow-direction`.

## Standard workflow

1. **Start from an up-to-date main:**
   ```bash
   git checkout main
   git pull
   git checkout -b feature/hero-section
   ```

2. **Work, then commit in small logical chunks** (not one giant commit at the end). Use Conventional Commits format:
   ```bash
   git add .
   git commit -m "feat: add hero section with video background"
   ```

3. **Push the branch (never main):**
   ```bash
   git push -u origin feature/hero-section
   ```

4. **Open a Pull Request** on GitHub, feature branch → main. Even solo, this gives a reviewable diff and a clean audit trail. Use `gh pr create` if the GitHub CLI is available:
   ```bash
   gh pr create --base main --head feature/hero-section --fill
   ```

5. **Review the diff yourself** before merging — this catches leftover console.logs, debug code, commented-out blocks, etc.

6. **Merge using "Squash and merge"** (via GitHub UI or `gh pr merge --squash`) so main gets one clean commit per feature instead of a pile of WIP commits.

7. **Clean up locally:**
   ```bash
   git checkout main
   git pull
   git branch -d feature/hero-section
   ```

## Commit message convention (Conventional Commits)

Format: `<type>: <short summary>`

| Type | Use for |
|---|---|
| `feat` | new feature or UI section |
| `fix` | bug fix |
| `chore` | setup, config, dependencies, tooling |
| `refactor` | restructuring code, no behavior change |
| `style` | CSS/formatting only |
| `docs` | README, comments |
| `perf` | performance improvement |
| `test` | adding/fixing tests |

Keep the summary imperative and short ("add", not "added" or "adding"). Add a body only if the "why" isn't obvious from the diff.

## Starting a brand-new repo (first commit)

```bash
git init
git add .
git commit -m "chore: initial project setup"
git branch -M main
git remote add origin <repo-url>
git push -u origin main
```

This first commit is the one exception — everything after this goes through feature branches.

## Handling work already sitting uncommitted on main

If the user (or Claude) has already been making changes directly on `main` and it's not pushed yet:

```bash
git checkout -b feature/whatever-this-is
git checkout main
git reset --hard origin/main   # only if main was already pushed clean before
```

Simpler and safer in most solo-project cases: just branch off from where you are — the branch will carry the uncommitted changes with it:

```bash
git checkout -b feature/whatever-this-is
git add .
git commit -m "feat: ..."
```

Then main is untouched and clean, and the new branch has the work.

## Common situations

**Fixing the last commit message:**
```bash
git commit --amend -m "fix: correct message"
```

**Un-staging files:**
```bash
git restore --staged <file>
```

**Merge conflict during PR:**
```bash
git checkout feature/my-branch
git pull origin main         # or: git merge main
# resolve conflicts in editor, then:
git add .
git commit
git push
```

**Quick hotfix needed on production while mid-feature:**
```bash
git stash                    # shelve current feature work
git checkout main
git pull
git checkout -b fix/urgent-bug
# fix, commit, push, PR, merge
git checkout feature/my-branch
git stash pop                # bring back the shelved work
```

## When NOT to over-engineer this

For solo freelance client projects, `feature-branch → main` is enough. Don't introduce a `dev`/staging branch layer unless the project has multiple environments or collaborators — that's added complexity with no payoff at this scale.

## Quick reference script

`scripts/new-branch.sh` automates the "am I on main, if so branch off" check — see that file for a copy-pasteable version.

## Trigger checklist (for the agent)

Before any `git commit`, `git push`, or when the user says they're starting new work:

1. Run `git branch --show-current`.
2. If it's `main`/`master` → create a properly named branch first (see naming convention above) before doing anything else.
3. If uncommitted changes already exist on `main` → branch off from the current state (`git checkout -b <name>`) so the changes move with it; do not reset or discard anything without asking.
4. Use a Conventional Commits message for every commit.
5. Never run `git push origin main` directly — only push feature branches.
6. When the user says they're "done" with a feature → push, open a PR (`gh pr create` if available, otherwise tell the user the branch is ready to PR manually), and remind them to squash-merge.
