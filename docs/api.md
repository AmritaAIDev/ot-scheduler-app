# API Documentation

The backend's full REST API reference — authentication, all resource endpoints, analytics endpoints, request/response examples, and the error code reference — lives in:

**[`backend/API_CATALOGUE.md`](../backend/API_CATALOGUE.md)**

It is kept alongside the backend code so it stays close to the Django URL configuration and views it documents (`backend/OT_Scheduling/urls.py`, `backend/OT_Scheduling/views.py`).

## Quick Facts

- **Base URL:** `http://<host>/api/`
- **Authentication mechanism:** JWT (`/api/login/`, `/api/token/refresh/`) is issued by the backend and would be validated as a Bearer token if sent.
- **Authentication enforcement (current state):** **not active.** Every `ModelViewSet`'s `permission_classes = [IsAuthenticated]` is commented out in `backend/OT_Scheduling/views.py`, no `DEFAULT_PERMISSION_CLASSES` is set, and the frontend never attaches the issued JWT to subsequent requests. In practice almost the entire API is reachable without credentials today — see [`docs/PRD.md`](PRD.md) §3/§5 (Gap #1/#2) for the full, code-verified finding. `UserUpdateView` is the one exception (`IsOwner`).
- **Framework:** Django REST Framework, routed via a mix of `DefaultRouter` viewsets and explicit `path()` views (see `backend/OT_Scheduling/urls.py`)

See [Architecture Overview](architecture.md) for how the frontend consumes this API.