# Admin Backend API Spec — Trips, Riders, Notifications, Settings

Spec for the four admin-panel screens that currently have **no backend
endpoint** (confirmed by route audit). Written to match the conventions already
in `Za2zoo2a-main` so the new endpoints slot in beside the existing admin
surface (`auth`, `pricing`, `drivers`, `selfie-checks`).

> No implementation here — this is the contract the admin panel will consume.
> Everything below is **additive**; it must not change any existing rider/driver
> route, since this one backend also serves the live mobile apps.

---

## 0. Shared conventions

These apply to every endpoint below; individual endpoints only note deviations.

### Mounting & auth
- All routes live under `/api/admin/*`, added to `src/routes/adminRoutes.ts`.
- Every route is guarded by the existing `requireAdmin` middleware
  (`[protect, restrictTo(UserRole.ADMIN)]`). No new auth mechanism.

### Success envelope
Use the existing `sendSuccess(res, data, message?, statusCode?)`:
```json
{ "success": true, "message": "Success", "data": { /* endpoint payload */ } }
```
Default `message` is `"Success"`, default `statusCode` is `200`.

### Error envelope
Throw `new ApiError(message, statusCode, data?)`; the global `errorHandler`
renders:
```json
{ "success": false, "message": "<message>" }
```
(`data` is included only when passed; `stack` only in development.)

### Pagination (all list endpoints)
- Query: `page` (int, optional, default `1`), `limit` (int, optional, default
  `20`, max `100`).
- Response always includes:
```json
"pagination": { "page": 1, "limit": 20, "total": 137, "pages": 7 }
```
`pages = Math.ceil(total / limit)`. Follow the exact shape `listDrivers` returns.

### Validation style
Manual guards that `throw new ApiError("<field> ...", 400)`, matching
`pricingController`/`adminDriverController` (not express-validator). A reason is
required for every destructive/override action, mirroring `reviewDocument` and
`blockDriver`.

### Errors common to all endpoints
| Code | When |
|------|------|
| `401` | Missing/invalid/expired bearer token (`protect`). |
| `403` | Valid token but `role !== "admin"` (`restrictTo`). |
| `429` | Global `/api` rate limit exceeded. |
| `500` | Unhandled server error. |

IDs are Mongo ObjectId strings (24 hex chars); an invalid-format `:id` returns
`400` ("Invalid id"), a well-formed-but-absent id returns `404`.

---

## 1. Riders

Backed by the existing `User` model (`role: "rider"`), plus `Wallet` and `Trip`
for the detail aggregates. Mirrors `listDrivers`/`getDriverDetail`.

### 1.1 `GET /api/admin/riders` — list (paginated)

**Auth:** admin only.

**Query params**
| Name | Type | Req | Notes |
|------|------|-----|-------|
| `page` | int | no | default 1 |
| `limit` | int | no | default 20, max 100 |
| `status` | string | no | `active` \| `blocked` → maps to `User.isActive` (`true`/`false`). Omit = all riders. |
| `search` | string | no | case-insensitive match on `fullName`, `email`, or `phone`. Omit = no filter. |

**Response 200** — `data`:
```json
{
  "riders": [
    {
      "id": "6a51…",
      "fullName": "Nour Adel",
      "email": "nour@example.com",
      "phone": "+2010…",
      "profilePhoto": "https://res.cloudinary.com/…"  ,
      "rating": 4.9,
      "totalRatings": 12,
      "isActive": true,
      "isVerified": true,
      "createdAt": "2026-03-12T10:00:00.000Z"
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total": 340, "pages": 17 }
}
```
Types: `rating` number, `totalRatings` int, `isActive`/`isVerified` bool,
`profilePhoto` string|null, dates ISO-8601 strings. Never return `password`,
`otp`, `refreshToken` (the `User.toJSON` already strips these).

**Errors:** `400` invalid `status` value; plus the common set.

---

### 1.2 `GET /api/admin/riders/:id` — detail

**Auth:** admin only. `:id` is the rider's `User._id`.

**Response 200** — `data`:
```json
{
  "rider": {
    "id": "6a51…",
    "fullName": "Nour Adel",
    "email": "nour@example.com",
    "phone": "+2010…",
    "profilePhoto": "https://…"  ,
    "rating": 4.9,
    "totalRatings": 12,
    "isActive": true,
    "isVerified": true,
    "createdAt": "2026-03-12T10:00:00.000Z"
  },
  "wallet": { "balance": 125.5, "currency": "EGP" },
  "stats": {
    "totalTrips": 84,
    "completedTrips": 80,
    "cancelledTrips": 4,
    "totalSpent": 3120.75
  }
}
```
- `wallet` is the rider's `Wallet` doc (`balance` number, `currency` string). If
  the rider has no wallet, return `{ "balance": 0, "currency": "EGP" }`.
- `stats.totalSpent` = sum of `fare.total` over that rider's `completed` trips.
- `stats.totalTrips` = count of all trips where `rider === :id`.

**Errors:** `404` "Rider not found" (no such user, or user's role is not
`rider`); plus common set.

### 1.3 (Optional) `PATCH /api/admin/riders/:id/block`

Only if rider blocking is wanted (the design shows a rider "block" action).
Identical contract to the existing `PATCH /api/admin/drivers/:id/block`:

**Body:** `{ "blocked": boolean (req), "reason": string (req when blocked=true) }`
Sets `User.isActive = !blocked`. **Response 200** `data: null`,
message `"Rider blocked: <reason>"` / `"Rider unblocked"`.
**Errors:** `400` if `blocked` not boolean, or `blocked=true` with no `reason`.

---

## 2. Trips

Backed by the existing `Trip` model. `rider` and `driver` are `User` refs to
populate. Requires **two small additive model changes** (see §5).

### 2.1 `GET /api/admin/trips` — list (paginated, filterable)

**Auth:** admin only.

**Query params**
| Name | Type | Req | Notes |
|------|------|-----|-------|
| `page` | int | no | default 1 |
| `limit` | int | no | default 20, max 100 |
| `status` | string | no | one of `TripStatus` (`requested`, `matching`, `accepted`, `driver_en_route`, `arrived`, `in_progress`, `completed`, `cancelled`). Omit = all. |
| `from` | string (ISO date) | no | inclusive lower bound on `requestedAt`. |
| `to` | string (ISO date) | no | inclusive upper bound on `requestedAt`. |
| `riderId` | string | no | filter by rider `User._id`. |
| `driverId` | string | no | filter by driver `User._id`. |

Sort newest first (`requestedAt: -1`), matching the `Trip` index
`{ status: 1, requestedAt: -1 }`.

**Response 200** — `data`:
```json
{
  "trips": [
    {
      "id": "6a90…",
      "status": "completed",
      "rider":  { "id": "6a51…", "fullName": "Nour Adel", "phone": "+2010…" },
      "driver": { "id": "6a41…", "fullName": "Ahmed Hassan", "phone": "+2011…" },
      "origin":      { "address": "Zamalek", "coordinates": { "lat": 30.06, "lng": 31.22 } },
      "destination": { "address": "New Cairo", "coordinates": { "lat": 30.03, "lng": 31.47 } },
      "fare":        { "total": 82.5, "surgeMultiplier": 1.2 },
      "distanceKm": 14.3,
      "payment": { "method": "card", "status": "completed" },
      "requestedAt": "2026-07-18T09:41:02.000Z",
      "completedAt": "2026-07-18T10:09:55.000Z"
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total": 12840, "pages": 642 }
}
```
- `driver` is `null` when a trip was never assigned.
- List rows may return the trimmed `fare` (`total`, `surgeMultiplier`); the full
  breakdown is on the detail endpoint.

**Errors:** `400` invalid `status`, or unparseable `from`/`to`; plus common set.

---

### 2.2 `GET /api/admin/trips/:id` — detail

**Auth:** admin only. `:id` is `Trip._id`. Unlike the rider/driver
`getTripById`, this is **not owner-scoped** — an admin may view any trip.

**Response 200** — `data.trip` is the full trip with `rider`/`driver` populated
(`id, fullName, phone, email, profilePhoto`) and every field:
```json
{
  "trip": {
    "id": "6a90…",
    "status": "completed",
    "rider":  { "id": "…", "fullName": "…", "phone": "…", "email": "…", "profilePhoto": "…"|null },
    "driver": { "id": "…", "fullName": "…", "phone": "…", "email": "…", "profilePhoto": "…"|null } | null,
    "origin":      { "address": "…", "coordinates": { "lat": 0, "lng": 0 } },
    "destination": { "address": "…", "coordinates": { "lat": 0, "lng": 0 } },
    "routePoints": [ { "lat": 0, "lng": 0 } ],
    "fare": {
      "baseFare": 5, "distanceFare": 60, "timeFare": 10, "bookingFee": 2,
      "discount": 0, "total": 82.5, "surgeMultiplier": 1.2
    },
    "distanceKm": 14.3,
    "estimatedDurationMin": 28,
    "actualDurationMin": 29,
    "payment": { "method": "card", "status": "completed", "transactionId": "…"|null },
    "riderRating": 5, "driverRating": 5,
    "cancellationReason": null, "cancelledBy": null,
    "fareOverride": null,
    "requestedAt": "…", "acceptedAt": "…", "startedAt": "…",
    "completedAt": "…", "cancelledAt": null,
    "createdAt": "…"
  }
}
```
`fareOverride` is `null` unless the fare was manually overridden (see §2.3 / §5).
Do **not** return `pin` (already `select: false`).

**Errors:** `404` "Trip not found"; plus common set.

---

### 2.3 `PATCH /api/admin/trips/:id/fare` — manual fare override

**Auth:** admin only.

**Body**
| Name | Type | Req | Notes |
|------|------|-----|-------|
| `total` | number | yes | new final fare; must be `>= 0`. |
| `reason` | string | yes | non-empty; recorded on the trip and in the audit log. |

**Behaviour**
- Reject with `409` if `trip.status === "cancelled"` (nothing to charge) —
  matches the "conflict on impossible state" convention.
- Sets `fare.total = total`, records `fareOverride` (see §5), writes an audit
  entry (`type: "override"`, §4.4).

**Response 200** — `data`:
```json
{ "trip": { /* full trip, as §2.2, with fareOverride populated */ } }
```
message `"Fare overridden"`.

**Errors:** `400` `total` missing/negative or `reason` empty; `404` trip not
found; `409` trip is cancelled; plus common set.

---

## 3. Notifications

The current `notificationController` is per-user and read-only; broadcasting
needs a **new admin controller** plus one **new model** for history (§5). The
send itself reuses the existing `notificationService.createNotification(...)`
and `fcmService` push pipeline — do not reinvent delivery.

### 3.1 `POST /api/admin/notifications` — send

**Auth:** admin only.

**Body**
| Name | Type | Req | Notes |
|------|------|-----|-------|
| `target` | string | yes | `single` \| `all_riders` \| `all_drivers` \| `everyone`. |
| `userId` | string | conditional | **required** when `target === "single"`; the recipient `User._id`. Ignored otherwise. |
| `title` | string | yes | 1–120 chars. |
| `body` | string | yes | 1–500 chars. |
| `type` | string | no | one of `NotificationType`; default `"system"`. Admin sends should use `system` or `promo`. |

**Behaviour**
- Resolve recipients:
  `single` → `[userId]`;
  `all_riders` → `User.find({ role: "rider", isActive: true })`;
  `all_drivers` → `User.find({ role: "driver", isActive: true })`;
  `everyone` → both.
- Create one in-app `Notification` per recipient and fire push (reuse
  `createNotification`; prefer a bulk `insertMany` + batched FCM for large
  targets — implementation detail, not contract).
- Persist one `NotificationCampaign` history row (§5).

**Response 201** — `data`:
```json
{
  "campaign": {
    "id": "6b01…",
    "title": "Rainy day — expect short surge",
    "target": "all_riders",
    "type": "system",
    "recipientCount": 38204,
    "sentBy": "6a55…",
    "createdAt": "2026-07-18T15:03:00.000Z"
  }
}
```
message `"Notification sent to <recipientCount> recipients"`.

**Errors:**
| Code | When |
|------|------|
| `400` | `target` not in the enum; `title`/`body` empty or over length; `type` invalid. |
| `400` | `target === "single"` and `userId` missing/!ObjectId. |
| `404` | `target === "single"` and no such user. |
| `422` | resolved recipient set is empty (e.g. `all_drivers` but none active) — nothing sent. |

---

### 3.2 `GET /api/admin/notifications` — sent history (paginated)

Reads from `NotificationCampaign` (the batch history), **not** the per-user
`Notification` collection.

**Auth:** admin only.

**Query:** `page`, `limit` (standard).

**Response 200** — `data`:
```json
{
  "campaigns": [
    {
      "id": "6b01…",
      "title": "Rainy day — expect short surge",
      "body": "Expect a brief surge between 3–5pm.",
      "target": "all_riders",
      "type": "system",
      "recipientCount": 38204,
      "sentBy": { "id": "6a55…", "name": "System Admin" },
      "createdAt": "2026-07-18T15:03:00.000Z"
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total": 57, "pages": 3 }
}
```
Sort newest first (`createdAt: -1`).

**Errors:** common set only.

---

## 4. Settings

Four sub-areas from the design: **commission rate**, **service zones**,
**support tickets**, **audit log**. Commission reuses the singleton pattern of
`PricingConfig`; the other three need new models (§5).

### 4.1 Commission / platform settings

Add `commissionRate` (percent the platform keeps per trip, `0–100`) as a new
field on the existing `PricingConfig` singleton — it is platform economics and
belongs with fares. Expose via dedicated settings routes so the Settings screen
stays separate from Pricing:

#### `GET /api/admin/settings`
**Response 200** — `data`:
```json
{ "settings": { "commissionRate": 20, "currency": "EGP" } }
```
`commissionRate` number (percent), `currency` string (read-only, from config).

#### `PATCH /api/admin/settings`
**Body:** `{ "commissionRate": number }` — required, `0 <= commissionRate <= 100`.
**Response 200** — `data: { "settings": { "commissionRate": 18, "currency": "EGP" } }`,
message `"Settings updated"`. Writes an audit entry (`type: "settings"`).
**Errors:** `400` `commissionRate` missing / not a number / out of `0–100`.

---

### 4.2 Service zones — CRUD (`Zone` model, §5)

#### `GET /api/admin/zones`
List (unpaginated — zones are few; a plain array is fine, matching how small
config lists are handled). **Response 200** — `data`:
```json
{
  "zones": [
    {
      "id": "6c01…",
      "name": "Central Cairo",
      "areas": ["Downtown", "Zamalek", "Garden City"],
      "surgeMultiplier": 1.2,
      "isActive": true,
      "driverCount": 142
    }
  ]
}
```
`driverCount` is optional/computed: count of online drivers whose
`currentLocation` falls within the zone's `center`+`radiusKm` **if that geo data
is set**, else `0`. (No geo membership exists today — see §5 note.)

#### `POST /api/admin/zones`
**Body**
| Name | Type | Req | Notes |
|------|------|-----|-------|
| `name` | string | yes | 1–80 chars, unique. |
| `areas` | string[] | no | free-text area labels; default `[]`. |
| `surgeMultiplier` | number | no | `>= 1`; default `1`. Per-zone surge override. |
| `isActive` | boolean | no | default `true`. |
| `center` | `{lat,lng}` | no | optional geo centre for future membership. |
| `radiusKm` | number | no | optional, `> 0`, required if `center` given. |

**Response 201** — `data: { "zone": { …as above… } }`, message `"Zone created"`.
**Errors:** `400` missing/blank `name`, `surgeMultiplier < 1`, `radiusKm <= 0`;
`409` duplicate `name`.

#### `PATCH /api/admin/zones/:id`
Body: any subset of the create fields. **Response 200** `data: { "zone": {…} }`,
message `"Zone updated"`. **Errors:** `400` invalid field; `404` zone not found;
`409` rename collision.

#### `DELETE /api/admin/zones/:id`
**Response 200** `data: null`, message `"Zone deleted"`.
**Errors:** `404` zone not found.

All zone mutations write an audit entry (`type: "zone"`).

---

### 4.3 Support tickets (`SupportTicket` model, §5)

Admin-facing read + triage. Ticket **creation** is a rider/driver-app concern
and is out of scope here (no such endpoint exists today).

#### `GET /api/admin/support-tickets` — list (paginated)
**Query:** `page`, `limit`, `status` (`open` | `pending` | `closed`, optional),
`priority` (`low` | `normal` | `high`, optional). Sort `createdAt: -1`.
**Response 200** — `data`:
```json
{
  "tickets": [
    {
      "id": "6d01…",
      "subject": "Driver took a longer route",
      "user": { "id": "6a51…", "name": "Nour Adel", "role": "rider" },
      "status": "open",
      "priority": "high",
      "createdAt": "2026-07-18T11:20:00.000Z",
      "updatedAt": "2026-07-18T11:20:00.000Z"
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total": 12, "pages": 1 }
}
```

#### `GET /api/admin/support-tickets/:id` — detail
**Response 200** — `data.ticket` adds `message` (string) and `replies`
(array of `{ body, by: {id,name,role:"admin"}, createdAt }`).
**Errors:** `404` ticket not found.

#### `PATCH /api/admin/support-tickets/:id` — update status
**Body:** `{ "status": "open"|"pending"|"closed" }` (required).
**Response 200** `data: { "ticket": {…} }`, message `"Ticket updated"`.
**Errors:** `400` invalid `status`; `404` not found.

#### `POST /api/admin/support-tickets/:id/replies` — reply
**Body:** `{ "body": string }` (required, 1–2000 chars).
**Response 201** `data: { "ticket": {…with new reply…} }`, message `"Reply added"`.
Optionally push a `Notification` to the ticket's user via `createNotification`.
**Errors:** `400` empty `body`; `404` not found.

---

### 4.4 Audit log (`AuditLog` model, §5)

**Read-only** list of admin actions. Critically, this model must be **written to
by the existing admin mutations** — every place the code already claims "recorded
in the audit log" (block/approve/document-review/pricing update) plus the new
mutations here (fare override, notification send, settings/zone changes) should
insert an `AuditLog` row. That write-instrumentation is part of shipping this.

#### `GET /api/admin/audit` — list (paginated)
**Query:** `page`, `limit`, `type` (optional filter), `actorId` (optional).
Sort `createdAt: -1`.
**Response 200** — `data`:
```json
{
  "entries": [
    {
      "id": "6e01…",
      "type": "pricing",
      "action": "Updated pricing · base fare 12 → 15 E£",
      "actor": { "id": "6a55…", "name": "System Admin" },
      "target": { "kind": "pricing", "id": "6a55…" } | null,
      "metadata": { "before": { "baseFare": 12 }, "after": { "baseFare": 15 } },
      "createdAt": "2026-07-18T09:12:00.000Z"
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total": 431, "pages": 22 }
}
```
`type` enum: `approve` | `block` | `document_review` | `selfie_review` |
`pricing` | `override` | `notify` | `settings` | `zone`.
`action` is a human-readable summary string. `target`/`metadata` optional.

**Errors:** `400` invalid `type` filter; plus common set.

---

## 5. New models & model changes required

Additive only. New models follow the existing Mongoose style (timestamps,
indexes, `_id` ObjectId).

| Model | Purpose | Key fields |
|-------|---------|-----------|
| **NotificationCampaign** (new) | history for §3 | `title`, `body`, `type` (NotificationType), `target` (enum single/all_riders/all_drivers/everyone), `targetUser?` (ObjectId ref User), `recipientCount` (int), `sentBy` (ObjectId ref User), timestamps. Index `{ createdAt: -1 }`. |
| **Zone** (new) | service zones §4.2 | `name` (unique), `areas` (string[]), `surgeMultiplier` (number, min 1, default 1), `isActive` (bool, default true), `center?` `{lat,lng}`, `radiusKm?` (number), timestamps. |
| **SupportTicket** (new) | §4.3 | `user` (ObjectId ref User), `role` (rider/driver), `subject`, `message`, `status` (open/pending/closed, default open), `priority` (low/normal/high, default normal), `replies` (`[{ body, by: ObjectId ref User, createdAt }]`), timestamps. Index `{ status: 1, createdAt: -1 }`. |
| **AuditLog** (new) | §4.4 | `type` (enum above), `action` (string), `actor` (ObjectId ref User), `targetKind?` (string), `targetId?` (ObjectId), `metadata?` (Mixed), timestamps. Index `{ createdAt: -1 }`, `{ type: 1, createdAt: -1 }`. |
| **PricingConfig** (change) | commission §4.1 | add `commissionRate` (number, default 20, min 0, max 100). |
| **Trip** (change) | fare override §2.3 | add `fareOverride?` `{ previousTotal: number, newTotal: number, reason: string, by: ObjectId ref User, at: Date }`. Update `fare.total` on override. |

### Route registrations (all in `adminRoutes.ts`, all `requireAdmin`)
```
GET   /api/admin/riders
GET   /api/admin/riders/:id
PATCH /api/admin/riders/:id/block            (optional)

GET   /api/admin/trips
GET   /api/admin/trips/:id
PATCH /api/admin/trips/:id/fare

POST  /api/admin/notifications
GET   /api/admin/notifications

GET   /api/admin/settings
PATCH /api/admin/settings
GET   /api/admin/zones
POST  /api/admin/zones
PATCH /api/admin/zones/:id
DELETE/api/admin/zones/:id
GET   /api/admin/support-tickets
GET   /api/admin/support-tickets/:id
PATCH /api/admin/support-tickets/:id
POST  /api/admin/support-tickets/:id/replies
GET   /api/admin/audit
```

---

## 6. Screen ↔ endpoint map (what the admin panel wires)

| Screen | Endpoints |
|--------|-----------|
| **Riders** | `GET /riders`, `GET /riders/:id` (+ optional block) |
| **Trips** | `GET /trips`, `GET /trips/:id`, `PATCH /trips/:id/fare` |
| **Notifications** | `POST /notifications`, `GET /notifications` |
| **Settings** | `GET/PATCH /settings`, `GET/POST/PATCH/DELETE /zones`, `GET /support-tickets` (+ `/:id`, `PATCH`, `/:id/replies`), `GET /audit` |

## 7. Notes / decisions to confirm

1. **Zone `driverCount`** is only real once drivers report a usable
   `currentLocation` (today it's `[0,0]`) and zones carry `center`+`radiusKm`.
   Until then it returns `0`. Flag if you want a different interim source.
2. **Per-zone `surgeMultiplier`** is stored but wiring it into fare calculation
   (overriding the global `PricingConfig.surgeMultiplier` inside a zone) is
   backend trip-pricing work beyond these read/write endpoints.
3. **Audit log** is only meaningful if the existing admin mutations are
   instrumented to write to it — that instrumentation is in scope for shipping
   §4.4, not just the read endpoint.
4. **Support ticket creation** (rider/driver side) is intentionally excluded;
   these endpoints assume tickets already exist.
