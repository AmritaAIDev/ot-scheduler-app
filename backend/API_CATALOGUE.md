# OT Scheduler — API Catalogue

**Base URL:** `http://<host>/api/`  
**Authentication:** JWT Bearer Token (except where noted as public)  
**Date format:** `YYYY-MM-DD` (query params) · `MM/DD/YYYY` (request/response bodies for surgery/patient dates)  
**Time format:** `HH:MM:SS`

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Doctors](#2-doctors)
3. [Operating Theatres (OTs)](#3-operating-theatres-ots)
4. [Patients](#4-patients)
5. [Procedures](#5-procedures)
6. [Scheduled Surgeries](#6-scheduled-surgeries)
7. [Monitoring](#7-monitoring)
8. [OT Staff](#8-ot-staff)
9. [OT Analytics](#9-ot-analytics)
10. [Doctor Analytics](#10-doctor-analytics)
11. [Department Analytics](#11-department-analytics)
12. [Procedure Analytics](#12-procedure-analytics)
13. [Surgery Type & Timing Analytics](#13-surgery-type--timing-analytics)
14. [Patient Analytics](#14-patient-analytics)
15. [OT Staff Analytics](#15-ot-staff-analytics)
16. [Utility](#16-utility)
17. [OT Scheduler (Algorithm)](#17-ot-scheduler-algorithm)
18. [Excel Processing](#18-excel-processing)

---

## Common Query Parameters (Analytics Endpoints)

All analytics endpoints accept optional date-range filters:

| Parameter    | Type   | Description              |
|--------------|--------|--------------------------|
| `start_date` | string | Format: `YYYY-MM-DD`     |
| `end_date`   | string | Format: `YYYY-MM-DD`     |

---

## 1. Authentication

### 1.1 Register User
`POST /api/register/`  
**Auth:** Public

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword",
  "name": "John Doe",
  "user_type": "admin"
}
```

**Response `201 Created`:**
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "user_type": "admin"
  },
  "access": "<jwt_access_token>",
  "refresh": "<jwt_refresh_token>"
}
```

**Response `400 Bad Request`:**
```json
{
  "email": ["This field is required."]
}
```

---

### 1.2 Get User
`GET /api/register/`  
**Auth:** Public

**Query Parameters (one required):**

| Parameter   | Type   | Description         |
|-------------|--------|---------------------|
| `id`        | int    | Filter by user ID   |
| `email`     | string | Filter by email     |
| `user_type` | string | Filter by user type |

**Response `200 OK`:**
```json
[
  {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "user_type": "admin"
  }
]
```

**Response `400 Bad Request`:**
```
"Please provide email id"
```

**Response `404 Not Found`:**
```
"User not found"
```

---

### 1.3 Login
`POST /api/login/`  
**Auth:** Public

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response `200 OK`:**
```json
{
  "access": "<jwt_access_token>",
  "refresh": "<jwt_refresh_token>",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "user_type": "admin"
  }
}
```

**Response `401 Unauthorized`:**
```json
{
  "detail": "No active account found with the given credentials"
}
```

---

### 1.4 Refresh Token
`POST /api/token/refresh/`  
**Auth:** Public

**Request Body:**
```json
{
  "refresh": "<jwt_refresh_token>"
}
```

**Response `200 OK`:**
```json
{
  "access": "<new_jwt_access_token>"
}
```

---

### 1.5 Update User Profile
`GET /api/user/update/`  
`PATCH /api/user/update/`  
**Auth:** Required (user can only update their own profile)

**Request Body (PATCH — email cannot be changed):**
```json
{
  "name": "Updated Name",
  "password": "newpassword"
}
```

**Response `200 OK`:**
```json
{
  "name": "Updated Name"
}
```

**Response `400 Bad Request`:**
```json
{
  "error": "Updating email is not allowed."
}
```

---

## 2. Doctors

Base path: `/api/doctors/`  
Standard ModelViewSet — supports `GET` (list/detail), `POST`, `PUT`, `PATCH`, `DELETE`.

### 2.1 List / Filter Doctors
`GET /api/doctors/`

**Query Parameters:**

| Parameter    | Type   | Description           |
|--------------|--------|-----------------------|
| `doctor_id`  | int    | Filter by primary key |
| `department` | string | Filter by department  |

**Response `200 OK`:**
```json
[
  {
    "doctor_id": 1,
    "doctor_name": "Dr. Sharma",
    "department": "Cardiology"
  }
]
```

---

### 2.2 Create Doctor
`POST /api/doctors/`

**Request Body:**
```json
{
  "doctor_name": "Dr. Sharma",
  "department": "Cardiology"
}
```

**Response `201 Created`:**
```json
{
  "doctor_id": 1,
  "doctor_name": "Dr. Sharma",
  "department": "Cardiology"
}
```

**Response `409 Conflict`:**
```json
{
  "detail": "Doctor with this Name and department already exists."
}
```

---

### 2.3 Retrieve Doctor
`GET /api/doctors/{doctor_id}/`

**Response `200 OK`:**
```json
{
  "doctor_id": 1,
  "doctor_name": "Dr. Sharma",
  "department": "Cardiology"
}
```

---

### 2.4 Update Doctor
`PUT /api/doctors/{doctor_id}/`  
`PATCH /api/doctors/{doctor_id}/`

**Request Body:**
```json
{
  "doctor_name": "Dr. Sharma Updated",
  "department": "Neurology"
}
```

**Response `200 OK`:** _(same as retrieve)_

---

### 2.5 Delete Doctor
`DELETE /api/doctors/{doctor_id}/`

**Response `204 No Content`**

---

## 3. Operating Theatres (OTs)

Base path: `/api/OT/`  
Standard ModelViewSet — supports `GET`, `POST`, `PUT`, `PATCH`, `DELETE`.

### 3.1 List / Filter OTs
`GET /api/OT/`

**Query Parameters:**

| Parameter    | Type   | Description            |
|--------------|--------|------------------------|
| `ot_id`      | int    | Filter by primary key  |
| `ot_number`  | string | Filter by OT number    |
| `department` | string | Filter by department   |

**Response `200 OK`:**
```json
[
  {
    "ot_id": 1,
    "ot_number": "OT-1",
    "department": "Cardiology"
  }
]
```

---

### 3.2 Create OT
`POST /api/OT/`

**Request Body:**
```json
{
  "ot_number": "OT-1",
  "department": "Cardiology"
}
```

**Response `201 Created`:**
```json
{
  "ot_id": 1,
  "ot_number": "OT-1",
  "department": "Cardiology"
}
```

**Response `409 Conflict`:**
```json
{
  "detail": "OT number with this department already exists."
}
```

---

### 3.3 Retrieve / Update / Delete OT
`GET /api/OT/{ot_id}/`  
`PUT /api/OT/{ot_id}/`  
`PATCH /api/OT/{ot_id}/`  
`DELETE /api/OT/{ot_id}/`

_(Standard CRUD responses)_

---

## 4. Patients

Base path: `/api/patient/`  
Standard ModelViewSet — supports `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, plus a custom bulk-delete action.

### 4.1 List / Filter Patients
`GET /api/patient/`

**Query Parameters:**

| Parameter           | Type   | Description                      |
|---------------------|--------|----------------------------------|
| `patient_id`        | int    | Filter by primary key            |
| `mrd`               | int    | Filter by MRD number             |
| `registration_date` | string | Filter by date (`YYYY-MM-DD`)    |

**Response `200 OK`:**
```json
[
  {
    "patient_id": 1,
    "patient_name": "Jane Doe",
    "age": 45,
    "mrd": 100123,
    "gender": "F",
    "registration_date": "01/15/2024"
  }
]
```

---

### 4.2 Create Patient
`POST /api/patient/`

**Request Body:**
```json
{
  "patient_name": "Jane Doe",
  "age": 45,
  "mrd": 100123,
  "gender": "F",
  "registration_date": "01/15/2024"
}
```

**Response `201 Created`:** _(same as list item)_

**Response `409 Conflict`:**
```json
{
  "detail": "Patient with this mrd already exists."
}
```

---

### 4.3 Delete All Patients on a Date
`DELETE /api/patient/delete-all-on-date/`

**Query Parameters:**

| Parameter           | Type   | Required | Description                   |
|---------------------|--------|----------|-------------------------------|
| `registration_date` | string | Yes      | Format: `YYYY-MM-DD`          |

**Response `204 No Content`:**
```json
{
  "message": "5 entries deleted successfully"
}
```

**Response `404 Not Found`:**
```json
{
  "message": "No entries found for the specified date."
}
```

---

## 5. Procedures

Base path: `/api/procedure/`  
Standard ModelViewSet — supports `GET`, `POST`, `PUT`, `PATCH`, `DELETE`.

### 5.1 List / Filter Procedures
`GET /api/procedure/`

**Query Parameters:**

| Parameter            | Type   | Description               |
|----------------------|--------|---------------------------|
| `procedure_id`       | int    | Filter by primary key     |
| `procedure_name`     | string | Filter by procedure name  |
| `department`         | string | Filter by department      |
| `estimated_duration` | float  | Filter by duration (hrs)  |

**Response `200 OK`:**
```json
[
  {
    "procedure_id": 1,
    "procedure_name": "Coronary Artery Bypass Graft",
    "department": "Cardiology",
    "estimated_duration": 4.5
  }
]
```

---

### 5.2 Create Procedure
`POST /api/procedure/`

**Request Body:**
```json
{
  "procedure_name": "Coronary Artery Bypass Graft",
  "department": "Cardiology",
  "estimated_duration": 4.5
}
```

**Response `201 Created`:** _(same as list item)_

**Response `409 Conflict`:**
```json
{
  "detail": "Procedure with this department already exists."
}
```

---

## 6. Scheduled Surgeries

Base path: `/api/schedule/`  
Standard ModelViewSet — supports `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, plus a custom bulk-delete action.

### 6.1 List / Filter Scheduled Surgeries
`GET /api/schedule/`

**Query Parameters:**

| Parameter              | Type   | Description                        |
|------------------------|--------|------------------------------------|
| `scheduled_surgery_id` | int    | Filter by primary key              |
| `patient_name`         | string | Filter by patient name             |
| `doctor_name`          | string | Filter by doctor name              |
| `ot_number`            | string | Filter by OT number                |
| `procedure_name`       | string | Filter by procedure name           |
| `user_id`              | int    | Filter by user who scheduled       |
| `status`               | string | Filter by status                   |
| `surgery_date`         | string | Filter by date (`YYYY-MM-DD`)      |
| `mrd`                  | string | Filter by MRD number               |
| `ot_staff_id`          | int    | Filter by OT staff                 |

**Response `200 OK`:**
```json
[
  {
    "scheduled_surgery_id": 1,
    "patient_name": "Jane Doe",
    "mrd": "100123",
    "doctor_name": "Dr. Sharma",
    "department": "Cardiology",
    "ot_number": "OT-1",
    "procedure_name": "CABG",
    "patient_id": 1,
    "doctor_id": 1,
    "ot_id": 1,
    "procedure_id": 1,
    "user_id": 1,
    "surgery_date": "01/15/2024",
    "surgery_start_time": "08:00:00",
    "surgery_end_time": "12:30:00",
    "status": "Scheduled",
    "ot_staff_id": null,
    "technician_tl": "Tech A",
    "nurse_tl": "Nurse B",
    "special_equipment": null
  }
]
```

---

### 6.2 Create Scheduled Surgery
`POST /api/schedule/`

**Request Body:**
```json
{
  "patient_name": "Jane Doe",
  "mrd": "100123",
  "doctor_name": "Dr. Sharma",
  "department": "Cardiology",
  "ot_number": "OT-1",
  "procedure_name": "CABG",
  "patient_id": 1,
  "doctor_id": 1,
  "ot_id": 1,
  "procedure_id": 1,
  "user_id": 1,
  "surgery_date": "01/15/2024",
  "surgery_start_time": "08:00:00",
  "surgery_end_time": "12:30:00",
  "status": "Scheduled",
  "technician_tl": "Tech A",
  "nurse_tl": "Nurse B"
}
```

**Response `201 Created`:** _(same as list item)_

---

### 6.3 Update Scheduled Surgery
`PUT /api/schedule/{scheduled_surgery_id}/`  
`PATCH /api/schedule/{scheduled_surgery_id}/`

Accepts any subset of fields to update.

**Response `200 OK`:** _(same as list item)_

---

### 6.4 Delete All Scheduled Surgeries on a Date
`DELETE /api/schedule/delete-all-on-date/`

**Query Parameters:**

| Parameter      | Type   | Required | Description          |
|----------------|--------|----------|----------------------|
| `surgery_date` | string | Yes      | Format: `YYYY-MM-DD` |

**Response `204 No Content`:**
```json
{
  "message": "8 entries deleted successfully"
}
```

---

## 7. Monitoring

Base path: `/api/monitor/`  
Standard ModelViewSet — supports `GET`, `POST`, `PUT`, `PATCH`, `DELETE`.

### 7.1 List / Filter Monitoring Records
`GET /api/monitor/`

**Query Parameters:**

| Parameter              | Type   | Description                   |
|------------------------|--------|-------------------------------|
| `scheduled_surgery_id` | int    | Filter by scheduled surgery   |
| `ot_number`            | string | Filter by OT number           |
| `user_id`              | int    | Filter by user                |
| `surgery_date`         | string | Filter by date (`YYYY-MM-DD`) |
| `technician_tl`        | string | Filter by technician          |

**Response `200 OK`:**
```json
[
  {
    "id": 1,
    "surgery_date": "01/15/2024",
    "scheduled_surgery_id": 1,
    "ot_number": "OT-1",
    "user_id": 1,
    "patient_received_in_pre_op_time": "07:30:00",
    "antibiotic_prophylaxis_time": "07:45:00",
    "patient_wheel_in_OT": "08:00:00",
    "induction_start_time": "08:05:00",
    "induction_end_time": "08:25:00",
    "painting_and_draping_start_time": "08:25:00",
    "painting_and_draping_end_time": "08:35:00",
    "incision_in_time": "08:35:00",
    "incision_close_time": "12:00:00",
    "extubation_time_in_OT": "12:15:00",
    "wheeled_out_time_to_Post_op_ICU": "12:30:00",
    "wheeled_out_from_Post_OP": "13:00:00",
    "procedure_name": "CABG",
    "estimated_duration": 4.5,
    "doctor_name": "Dr. Sharma",
    "ot_staff_id": null,
    "technician_tl": "Tech A",
    "nurse_tl": "Nurse B",
    "special_equipment": null,
    "surgery_type": "Pre-planned"
  }
]
```

---

### 7.2 Create Monitoring Record
`POST /api/monitor/`

**Request Body:** _(same fields as above, `id` excluded)_

**Response `201 Created`:** _(same as list item)_

---

## 8. OT Staff

Base path: `/api/otstaff/`  
Standard ModelViewSet — supports `GET`, `POST`, `PUT`, `PATCH`, `DELETE`.

### 8.1 List OT Staff
`GET /api/otstaff/`

**Response `200 OK`:**
```json
[
  {
    "ot_staff_id": 1,
    "ot_staff_employee_id": "EMP-001",
    "ot_staff_name": "Alice Kumar",
    "ot_staff_department": "Cardiology",
    "ot_staff_designation": "Nurse T/L"
  }
]
```

---

### 8.2 Create OT Staff
`POST /api/otstaff/`

**Request Body:**
```json
{
  "ot_staff_employee_id": "EMP-001",
  "ot_staff_name": "Alice Kumar",
  "ot_staff_department": "Cardiology",
  "ot_staff_designation": "Nurse T/L"
}
```

**Response `201 Created`:** _(same as list item)_

**Response `409 Conflict`:**
```json
{
  "detail": "OT staff with this department and designation already exists."
}
```

---

## 9. OT Analytics

### 9.1 OT Count
`GET /api/ot-count/`

Returns the count of unique OTs used within the date range.

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "message": "Count of unique OT numbers between 08/01/2022 and 12/31/2023: 11"
}
```

---

### 9.2 Surgeries per OT
`GET /api/ot-surgery-count/`

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "Count of surgeries per OT from 2022-08-01 to 2023-12-31": [
    { "OT-1": 120 },
    { "OT-2": 95 },
    { "OT-3": 88 }
  ]
}
```

---

### 9.3 OT Time Slot Usage (Heatmap)
`GET /api/ot-time-slot-usage/`

Returns surgery counts per OT broken down by 2-hour time slots.

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "time_slots": [
    "08:00 - 09:59",
    "10:00 - 11:59",
    "12:00 - 13:59",
    "14:00 - 15:59",
    "16:00 - 17:59"
  ],
  "ot_usage": {
    "OT-1": [12, 18, 15, 10, 6],
    "OT-2": [9, 14, 11, 8, 4]
  }
}
```

---

### 9.4 Average Monitoring Step Durations per OT
`GET /api/monitoring-steps-avg/`

Returns average durations (in seconds) for each surgical workflow step, grouped by OT.

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
[
  {
    "ot_number": "OT-1",
    "avg_pre_op_to_ot": 1800000000,
    "avg_induction_duration": 1200000000,
    "avg_painting_and_draping_duration": 600000000,
    "avg_incision_duration": 10800000000,
    "avg_extubation_duration": 900000000,
    "avg_incision_to_extubation": 600000000,
    "avg_wheeled_duration": 1800000000
  }
]
```

> Note: Duration values are in microseconds (Django DurationField serialized format).

---

### 9.5 OT Utilization Percentage
`GET /api/percent-ot-utilization/`

Calculates each OT's utilization as a percentage of available time (10 hrs/day).  
**Both `start_date` and `end_date` must be provided together** (or both omitted for all-time).

**Query Parameters:** `start_date`, `end_date` _(both required together)_

**Response `200 OK`:**
```json
[
  { "OT-1": 72.45 },
  { "OT-2": 65.30 }
]
```

**Response `200 OK` (missing one date):**
```json
{
  "message": "please enter the end date."
}
```

---

### 9.6 Average Time Difference Between Consecutive Surgeries
`GET /api/avg-time-difference/`

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
[
  {
    "ot_number": "OT-1",
    "avg_time_difference": "0:28:00"
  }
]
```

**Response `404 Not Found`:**
```json
{
  "message": "No data found for the specified date range."
}
```

---

## 10. Doctor Analytics

### 10.1 Doctor Count
`GET /api/doctor-count/`

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "message": "Count of unique doctors from 01/01/2023 to 12/31/2023: 24"
}
```

---

### 10.2 Surgeries per Doctor
`GET /api/doctor-surgery-count/`

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "Count of surgeries per doctor from 2023-01-01 to 2023-12-31": [
    { "Dr. Sharma": 45 },
    { "Dr. Patel": 38 }
  ]
}
```

---

### 10.3 Doctor Time Slot Usage (Heatmap)
`GET /api/doctor-time-slot-usage/`

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "time_slots": [
    "08:00 - 09:59",
    "10:00 - 11:59",
    "12:00 - 13:59",
    "14:00 - 15:59",
    "16:00 - 17:59"
  ],
  "doctor_usage": {
    "Dr. Sharma": [5, 8, 6, 4, 2],
    "Dr. Patel": [3, 7, 5, 3, 1]
  }
}
```

---

### 10.4 Average Surgery Duration per Doctor
`GET /api/doctor-average-time/`

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "message": [
    { "Dr. Sharma": "4:30:00" },
    { "Dr. Patel": "3:15:00" }
  ]
}
```

---

## 11. Department Analytics

### 11.1 Department Count
`GET /api/department-count/`

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "message": "Count of departments from 2023-01-01 to 2023-12-31: 8"
}
```

---

### 11.2 Surgery Count per Department
`GET /api/surgery-department-count/`

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "message": [
    { "Cardiology": 120 },
    { "Neurology": 85 }
  ]
}
```

---

### 11.3 Unique Surgery Count per Department
`GET /api/unique-department-surgery-count/`

Returns distinct procedures grouped by department.

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "Cardiology": [
    { "procedure_name": "CABG", "count": 40 },
    { "procedure_name": "Valve Replacement", "count": 30 }
  ],
  "Neurology": [
    { "procedure_name": "Craniotomy", "count": 25 }
  ]
}
```

**Response `404 Not Found`:**
```json
{
  "message": "No surgeries found for the specified date range"
}
```

---

## 12. Procedure Analytics

### 12.1 Total Procedure Count
`GET /api/procedure-count/`

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "message": [
    { "Total number of procedures from 2023-01-01 to 2023-12-31": 450 }
  ]
}
```

---

### 12.2 Procedure Time Comparison by Doctor
`GET /api/procedure-time-comparison/`

Returns average surgery duration per procedure broken down by doctor.

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
[
  {
    "procedure_name": "CABG",
    "doctors": [
      { "doctor_name": "Dr. Sharma", "average_duration": "4:30:00" },
      { "doctor_name": "Dr. Patel", "average_duration": "5:00:00" }
    ]
  }
]
```

---

## 13. Surgery Type & Timing Analytics

### 13.1 Surgery Type Percentage
`GET /api/surgery-type-percentage/`

Returns percentage breakdown of Emergency, Add-on, and Pre-planned surgeries.

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "message": [
    { "emergency_percentage": 12.50 },
    { "add_on_percentage": 18.75 },
    { "pre_planned_percentage": 68.75 },
    { "total_surgeries": 400 }
  ]
}
```

---

### 13.2 Surgery Timing Percentage (On-time vs Delayed)
`GET /api/surgery-timing-percentage/`

Compares actual duration vs estimated duration to classify surgeries.

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "message": [
    { "delayed_percentage": 32.10 },
    { "on_time_percentage": 67.90 },
    { "total_surgeries": 380 }
  ]
}
```

---

## 14. Patient Analytics

### 14.1 Patient Count
`GET /api/patient-count/`

**Query Parameters:** `start_date`, `end_date` _(optional, filters on `registration_date`)_

**Response `200 OK`:**
```json
{
  "message": [
    { "total_patients": 320 },
    {
      "date_range": {
        "start_date": "2023-01-01",
        "end_date": "2023-12-31"
      }
    }
  ]
}
```

---

### 14.2 Gender Distribution
`GET /api/gender-distribution/`

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "message": [
    { "Female": 48.75 },
    { "Male": 51.25 },
    { "total_patients": 320 }
  ]
}
```

---

### 14.3 Age Distribution
`GET /api/age-distribution/`

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "age_distribution": [
    { "age_group": "0-18", "count": 25, "percentage": 7.81 },
    { "age_group": "19-35", "count": 80, "percentage": 25.0 },
    { "age_group": "36-60", "count": 150, "percentage": 46.88 },
    { "age_group": "61+", "count": 65, "percentage": 20.31 }
  ]
}
```

---

## 15. OT Staff Analytics

### 15.1 OT Staff Count
`GET /api/ot_staff_count/`

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "message": "Count of OT Staff between 01/01/2023 and 12/31/2023: 15"
}
```

---

### 15.2 Surgery Count per OT Staff
`GET /api/otstaff-surgery-count/`

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "Count of surgeries per staff from 2023-01-01 to 2023-12-31": [
    { "staff_name": "Tech A", "count": 62 },
    { "staff_name": "Tech B", "count": 55 }
  ]
}
```

---

### 15.3 Average Surgery Duration per OT Staff
`GET /api/otstaff-avg-time/`

**Query Parameters:** `start_date`, `end_date` _(optional)_

**Response `200 OK`:**
```json
{
  "message": [
    { "staff_name": "Tech A", "duration": "3:45:00" },
    { "staff_name": "Tech B", "duration": "4:10:00" }
  ]
}
```

---

## 16. Utility

### 16.1 Surgery Date Range
`GET /api/date-range/`

Returns the earliest and latest surgery dates available in the monitoring data.

**Auth:** Required  
**Query Parameters:** None

**Response `200 OK`:**
```json
[
  { "earliest date": "2022-08-01" },
  { "latest date": "2023-12-31" }
]
```

---

## 17. OT Scheduler (Algorithm)

### 17.1 Generate OT Schedule
`POST /api/ot-schedule/`

Accepts a base64-encoded Excel file containing the surgery list, runs the scheduling algorithm (priority-based, equipment-aware, no-overlap), and returns the full schedule.

**Auth:** Required  
**Content-Type:** `application/json`

**Expected Excel Columns (in order):**

| Column            | Description                      |
|-------------------|----------------------------------|
| `DATE OF SURGERY` | Surgery date                     |
| `AGE/SEX`         | e.g. `45Y/M`                     |
| `SURGERY`         | Surgery/procedure name           |
| `SURGEON`         | Surgeon name                     |
| `DEPARTMENT`      | Department name                  |
| `Name of the Patient` | Patient name               |
| `Special Request` | Special equipment needed (or NA) |
| `MRD`             | Patient MRD number               |
| `Duration`        | Estimated duration in hours      |
| `Bed No`          | Bed number                       |
| `Contact no`      | Contact number                   |
| `Requirement ICU` | _(optional)_                     |
| `Anaesthesiologist` | _(optional)_                   |
| `PAC Status`      | _(optional)_                     |
| `FIC Clearance`   | _(optional)_                     |

**Request Body:**
```json
{
  "doc": "<base64_encoded_excel_file_string>"
}
```

**Response `200 OK`:**

Returns a dictionary representation of the schedule DataFrame. Each key is a column name and its value is a dict of `{row_index: value}`.

```json
{
  "Date of Surgery": { "0": "01/15/2024", "1": "01/15/2024" },
  "Age/Sex": { "0": "45Y/M", "1": "32Y/F" },
  "surgery": { "0": "CABG", "1": "Appendectomy" },
  "Surgeon": { "0": "Dr. Sharma", "1": "Dr. Patel" },
  "Department": { "0": "Cardiology", "1": "General Surgery" },
  "Name of the Patient": { "0": "Jane Doe", "1": "John Smith" },
  "Special Equipment": { "0": "NA", "1": "NA" },
  "MRD": { "0": "100123", "1": "100124" },
  "Bed No": { "0": "B-12", "1": "B-15" },
  "Contact No": { "0": "9876543210", "1": "9123456789" },
  "Nursing T/L": { "0": "Nurse A", "1": "Nurse B" },
  "Technicial T/L": { "0": "Tech A", "1": "Tech B" },
  "OT": { "0": 1, "1": 2 },
  "Start_time": { "0": "8:00", "1": "8:30" },
  "End_time": { "0": "12:30", "1": "10:00" },
  "Requirement ICU": { "0": "NA", "1": "NA" },
  "Anaesthesiologist": { "0": "NA", "1": "NA" },
  "PAC Status": { "0": "NA", "1": "NA" },
  "FIC Clearance": { "0": "NA", "1": "NA" }
}
```

**Response `400 Bad Request`:**
```json
{
  "message": "All rows contained null values and have been removed."
}
```

> **Algorithm behaviour:**  
> - Surgeries are sorted by priority: long-duration first, then paediatric (age < 12), then remaining by duration descending.  
> - OT assignment respects department preferences from `OT preferences(1).xlsx`.  
> - Two scheduling phases: day shift (08:00–18:00) then night shift (18:00–24:00).  
> - Doctor and patient overlap prevention is enforced.  
> - Special equipment availability is tracked per slot.  
> - 30-minute buffer is added between surgeries in the same OT.  
> - The output Excel is also saved to `OT_Scheduling/assets/outputs/`.

---

## 18. Excel Processing

### 18.1 Parse and Standardize Surgery Excel
`POST /api/parse-excel/`

Accepts a multipart form upload of an Excel file. For each row, it fuzzy-matches the surgery name against the standard surgery names database and returns standardized names, surgery codes, and estimated durations.

**Auth:** Public  
**Content-Type:** `multipart/form-data`

**Expected Excel Columns:**

| Column               | Description                             |
|----------------------|-----------------------------------------|
| `DATE OF SURGERY`    | Surgery date                            |
| `AGE/SEX`            | Age and sex string e.g. `45Y/M`        |
| `SURGERY`            | Raw surgery name (to be standardized)   |
| `SURGEON`            | Surgeon name                            |
| `SPECIALITY`         | Medical speciality / department         |
| `Name of the Patient`| Patient name                            |
| `Special Request`    | Special equipment needed                |
| `Mrd Number`         | Patient MRD number                      |
| `Contact No`         | Contact number                          |
| `Bed No`             | Bed number                              |
| `Requirement ICU`    | _(optional)_                            |
| `Anaesthesiologist`  | _(optional)_                            |
| `PAC Status`         | _(optional)_                            |
| `FIC Clearance`      | _(optional)_                            |

**Request:**
```
POST /api/parse-excel/
Content-Type: multipart/form-data

file=<excel_file.xlsx>
```

**Response `200 OK`:**
```json
[
  {
    "DATE OF SURGERY": "2024-01-15T00:00:00",
    "AGE/SEX": "45Y/M",
    "SURGERY": ["Coronary Artery Bypass Graft"],
    "SURGERY_CODE": ["C-101"],
    "SURGEON": "Dr. Sharma",
    "SPECIALITY": "Cardiology",
    "Name of the Patient": "Jane Doe",
    "Special Request": null,
    "Mrd Number": 100123,
    "duration": [4.5],
    "Contact no": "9876543210",
    "Bed No": "B-12",
    "Requirement ICU": null,
    "Anaesthesiologist": null,
    "PAC Status": null,
    "FIC Clearance": null
  }
]
```

> **Notes:**  
> - `SURGERY` and `SURGERY_CODE` are arrays because a single surgery name may be split on `+`, `&`, `,`, or `and`.  
> - `duration` is an array aligned to the `SURGERY` array (hours as float, or `null` if not found).  
> - `null` is returned for any missing/empty cell values.  
> - Matching uses a 5-stage cascade: abbreviation dominance → TF-IDF cosine similarity → word overlap → spelling/root similarity → longest common substring.

**Response `400 Bad Request`:**
```json
{
  "error": "No file uploaded"
}
```

---

### 18.2 Get Surgery Duration by Name
`GET /api/surgery-duration/`

Looks up an estimated surgery duration for a given surgery name string using the same fuzzy-matching logic as the Excel processor.

**Auth:** Public

**Query Parameters:**

| Parameter      | Type   | Required | Description              |
|----------------|--------|----------|--------------------------|
| `surgery_name` | string | Yes      | Surgery name to look up  |

**Response `200 OK`:**
```json
{
  "surgery_name": "Coronary Artery Bypass Graft",
  "estimated_duration": 4.5
}
```

**Response `400 Bad Request`:**
```json
{
  "error": "'surgery_name' is required."
}
```

**Response `404 Not Found`:**
```json
{
  "error": "No matching surgery found."
}
```

---

## Error Reference

| Status Code | Meaning                                     |
|-------------|---------------------------------------------|
| `200`       | Success                                     |
| `201`       | Resource created                            |
| `204`       | Resource deleted (no content returned)      |
| `400`       | Bad request / validation error              |
| `401`       | Unauthorized — invalid or missing JWT token |
| `403`       | Forbidden — insufficient permissions        |
| `404`       | Resource not found                          |
| `409`       | Conflict — duplicate resource               |
