# API Documentation

The backend's full REST API reference — authentication, all resource endpoints, analytics endpoints, request/response examples, and the error code reference — lives in:

**[`backend/API_CATALOGUE.md`](../backend/API_CATALOGUE.md)**

It is kept alongside the backend code so it stays close to the Django URL configuration and views it documents (`backend/OT_Scheduling/urls.py`, `backend/OT_Scheduling/views.py`).

## Quick Facts

- **Base URL:** `http://<host>/api/`
- **Authentication:** JWT Bearer token (`/api/login/`, `/api/token/refresh/`), except where the catalogue marks an endpoint public
- **Framework:** Django REST Framework, routed via a mix of `DefaultRouter` viewsets and explicit `path()` views (see `backend/OT_Scheduling/urls.py`)

See [Architecture Overview](architecture.md) for how the frontend consumes this API.