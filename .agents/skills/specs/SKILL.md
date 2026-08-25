---
name: specs
description: Create a feature specification document in the specs/ directory after checking git status and creating a dedicated git feature branch.
---

# Feature Specification Creation (/specs)

Use this workflow whenever the user runs `/specs` or requests a detailed specification document for a task/feature.

## Workflow Execution Steps

### 1. Check Git Repository Status
Run `git status --porcelain` before making any branch changes or creating files.

- **If the working tree is dirty** (uncommitted additions, modifications, or deletions exist):
  - **STOP execution immediately**.
  - Output a clear message to the user:
    > ⚠️ **Git status is not clean.** Please commit, stash, or discard your uncommitted changes before running `/specs`.
  - Do NOT create a new branch or generate any specification file.

### 2. Create Feature Git Branch
If `git status --porcelain` returns an empty output (clean working tree):
- Format the task parameters into a sanitized branch name slug (e.g., `01 first task` → `feature/01-first-task` or `feature/01-auth-feature`).
- Execute `git checkout -b <branch_name>`.

### 3. Generate Feature Specification Document
Create a new Markdown file inside the `specs/` directory:
Path: `specs/<task_slug>.md` (e.g., `specs/01_first_task.md` or `specs/01_auth_feature.md`).

The specification file must include:
1. **Overview & Goal**: Objectives and target user experience.
2. **API & Data Contracts**: Relevant REST/SSE endpoints from `api_docs.md` with exact schemas.
3. **Layered Architecture Breakdown**:
   - `data/` (Remote data sources, Repositories, DTOs)
   - `domain/` (Entities & repository interfaces if needed)
   - `presentation/` (Riverpod providers/notifiers, Screens, Widgets)
4. **State Management Design**: State classes, Riverpod providers (`AsyncValue<T>`), side effects, loading/error states.
5. **UI & Responsive Layout Guidelines**: Key visual components, widget hierarchy, material 3 theme integration.
6. **Testing & Verification Checklist**: Unit test targets, provider state tests, widget tests, and `flutter analyze` verification commands.
