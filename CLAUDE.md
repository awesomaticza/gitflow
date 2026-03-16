# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **GitFlow automation toolkit** designed to be consumed as a **git submodule** at `.gitflow/` inside other projects. It provides shell scripts that automate the GitFlow branching and release workflow via `make` commands.

## Commands

```bash
make help     # List all available commands
make release  # Create a release branch and open a PR to master (must be on develop)
make release COMMIT_HASH=<sha>  # Release from a specific commit on develop
make hotfix   # Create a hotfix branch and open a PR to master (must be on master)
```

The Makefile in this repo is meant to be included by a consumer project's root Makefile:
```makefile
GITFLOW_DIR := .gitflow
include $(GITFLOW_DIR)/Makefile
```

## Architecture

### How It Works as a Submodule

Consumer projects add this repo as a submodule at `.gitflow/`:
```bash
git submodule add git@github.com:awesomaticza/gitflow.git .gitflow
```

The consumer project's root `Makefile` includes this repo's `Makefile`, which delegates to `scripts/release.sh` and `scripts/hotfix.sh`.

### Script Behaviour

**`scripts/release.sh`** (run from `develop` branch):
1. Reads the release version from Maven `pom.xml` (strips `-SNAPSHOT` suffix)
2. Creates branch `release/x.y.z` from develop
3. Updates `pom.xml` version via `mvn versions:set`
4. Commits, pushes, and opens a PR targeting `master` via `gh pr create`

**`scripts/hotfix.sh`** (run from `master` branch):
1. Finds the latest git tag on master (must match `X.Y.Z` semver)
2. Increments the patch version automatically
3. Creates branch `hotfix/x.y.z` from the latest tag (not HEAD of master)
4. Updates `pom.xml` version via `mvn versions:set`
5. Commits, pushes, and opens a PR targeting `master` via `gh pr create`

After a release or hotfix PR merges to master, a GitHub Actions workflow is expected to create a back-merge PR into `develop`.

### Required Tools (in Consumer Projects)

- **`gh`** (GitHub CLI) — must be authenticated (`gh auth login`)
- **`mvn`** (Maven) — must have a `pom.xml` in the project root; used for version management
- **`make`** — delegates commands from the consumer project to this submodule

### Artifacts

- `artifacts/drawio/` — editable DrawIO source files for all workflow diagrams
- `artifacts/images/` — exported PNG images referenced in `README.md` and `How-To Guide.md`

### Branch Naming Conventions

| Branch type | Pattern | Source |
|-------------|---------|--------|
| Feature | `feature/*` | `develop` |
| Release | `release/x.y.z` | `develop` |
| Hotfix | `hotfix/x.y.z` | latest tag on `master` |
| Main | `master`, `develop` | — |

## Key Files

- `scripts/release.sh` — interactive release automation script
- `scripts/hotfix.sh` — interactive hotfix automation script
- `Makefile` — exposes `release` and `hotfix` targets; meant to be included by consumer projects
- `How-To Guide.md` — step-by-step integration guide for consumer project teams

## Standard Workflow
> NOTE:
> 1. Most prompts will be provided via file in the `tasks/specifications` folder. For example, for a prompt file called
     > `01-first-feature.md`, create the associated execution plan in the `tasks/features` folder in a file called `01-first-feature.md`.
     > If the prompt is asked via command line create an appropriately named file in the `tasks/features` folder.
> 2. DO NOT create a file in the `tasks/features` folder for very simply prompts from the command line like the ones that don't need any or extensive code changes.
> 3. Details of bugs will be written in the `tasks/bugs` folder. Create an appropriately named file in the `tasks/fixes` folder.
1. First think through the problem, read the codebase for relevant files, and write a plan to an appropriately named file in the `tasks/features` folder.
2. The plan should have a list of todo items that can be checked off as the items are completed
3. Before you begin the work, check in with me and I will verify the plan.
4. Begin working on the todo items, mark them complete as you progress through the items.
5. After each todo item is marked complete, verify the change in isolation before proceeding:
- Run any existing tests relevant to the modified code and confirm nothing is broken
- If no tests exist for the changed area, briefly describe the manual verification performed (e.g. "ran the pipeline locally", "confirmed the Lambda deployed and returned 200")
- If the change introduced new logic, add or suggest a test that would catch a regression
- Do not proceed to the next todo item if verification fails — re-examine the change and resolve before moving forward
6. Provide a high-level explanation of the changes made in every step
7. Make every task and code change as simple as possible. Avoid making massive or complex changes. Every change should impact as little code as possible. Everything is about simplicity.
8. Finally, add a review section to the file in the `tasks/features` folder with a summary of changes made and any other relevant information.

## Project in Plain English
For every project, write a detailed ProjectInPlainEnglish.md file that explains the whole project in plain language. Explain the technical architecture, the structure of
the codebase and how the various parts are connected, the technologies used, why we made these technical decisions, and lessons I can learn from it
(this should include the bugs we ran into and how we fixed them, potential pitfalls and how to avoid them in the future, new technologies used,
how good engineers think and work, best practices, etc). It should be very engaging to read; don’t make it sound like boring technical documentation.
Where appropriate, use analogies and anecdotes to make it more understandable and memorable.

## Diagrams
Draw all diagrams using Mermaid - provide a good contrast between font and fill-in colours.
