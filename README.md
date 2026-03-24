# Task Management App

**Track A — Full-Stack (Flutter + FastAPI + SQLite)**

## Setup

### Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload
```

### Flutter
```bash
cd frontend
flutter pub get
flutter run
```

> Android emulator: the API base URL is already set to `10.0.2.2:8000` in `lib/services/api_service.dart`.

## Features implemented
- Full CRUD via REST API
- Task fields: title, description, due date, status, blocked_by
- Blocked tasks shown greyed-out with a lock icon
- Draft persistence (SharedPreferences) on new task screen
- Search by title + filter by status
- 2-second simulated delay on create/update with loading indicator
- Save button disabled while request is in-flight

## Stretch Goal
None chosen (picked clean core over a rushed stretch goal).

## AI Usage
Used Claude to scaffold boilerplate and suggest the `isBlocked()` logic.
The initial `blocked_by` foreign-key self-reference caused a circular
dependency warning in SQLAlchemy — fixed by adding `use_alter=True` to the
ForeignKey call (though SQLite doesn't enforce FKs anyway, it kept the
model clean).