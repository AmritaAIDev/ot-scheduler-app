# Monorepo Migration

The OT Scheduler backend and frontend previously lived in separate repositories. They were combined into this single repository using `git subtree`, which preserves each project's original commit history inside its new subdirectory.

## History

The migration was performed in three steps, visible in the repository's git log:

1. **Initial commit** (`8afa9d0`) — created the new monorepo with a placeholder root `README.md`.
2. **`git subtree add --prefix=backend`** (`822c88a`) — merged in the backend repository's full history at commit `cc0a7a0`, placing it under [`backend/`](../backend).
3. **`git subtree add --prefix=frontend`** (`87440f3`) — merged in the frontend repository's full history at commit `5d4b51c`, placing it under [`frontend/`](../frontend).

You can see this in the log:

```
git log --oneline --graph
```

Each subtree merge commit records the source commit hash it was split from (`git-subtree-dir` / `git-subtree-split` trailers), so the pre-migration history of each project remains traceable.

## What changed

- Backend and frontend code moved into `backend/` and `frontend/` respectively; no application code was altered as part of the migration.
- Each project keeps its own dependency manifest (`backend/requirements.txt`, `frontend/pubspec.yaml`) and is set up independently — see [Development](development.md).
- Project-wide documentation (this `docs/` directory and the root [`README.md`](../README.md)) is new, added to give the monorepo a single entry point.

## What did not change

- Deployment is still manual/per-project — see [`backend/Backend_Deployment_README.md`](../backend/Backend_Deployment_README.md) and the deployment section of [`frontend/README.md`](../frontend/README.md). No CI/CD was introduced as part of this reorganization.
- Backend and frontend still run and are configured independently of each other (no shared build tooling).