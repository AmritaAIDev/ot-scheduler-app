# Development Guide

This is a monorepo containing two independently-run projects. There is no shared build system — set up and run each project separately.

## Repository Layout

| Path | Purpose |
|------|---------|
| [`backend/`](../backend) | Django REST Framework API |
| [`frontend/`](../frontend) | Flutter client app |
| [`docs/`](.) | Project-wide documentation (this directory) |

## Working on the Backend

Follow [`backend/README.md`](../backend/README.md) for prerequisites, local setup, environment configuration, database migrations, and running the Django dev server.

The backend exposes its API under `/api/`, cataloged in full in [`backend/API_CATALOGUE.md`](../backend/API_CATALOGUE.md).

## Working on the Frontend

Follow [`frontend/README.md`](../frontend/README.md) for prerequisites and how to run the Flutter app.

The frontend's API base URL is set in `frontend/lib/config/constants.dart` and must point at a running instance of the backend (local or remote) for the app to function.

## Running Both Together Locally

1. Start the backend (see `backend/README.md`) — by default it serves on `http://localhost:8000`.
2. Confirm `baseURL` in `frontend/lib/config/constants.dart` matches the backend's address (the default in the file is `http://localhost:8000/api`).
3. Start the frontend (see `frontend/README.md`).

## Testing

- Backend: Django's test scaffolding is present at `backend/OT_Scheduling/tests.py`, but no tests are currently implemented there.
- Frontend: a Flutter widget test scaffold exists at `frontend/test/widget_test.dart`, but it is currently empty.

## Related Documentation

- [Architecture Overview](architecture.md)
- [API Catalogue](../backend/API_CATALOGUE.md)
- [Monorepo Migration History](migration.md)