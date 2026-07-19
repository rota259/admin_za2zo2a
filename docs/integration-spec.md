# Integration Spec — Mobile App ↔ Backend ↔ Admin Console

How each admin feature round-trips through the shared backend to the rider/
driver **Flutter mobile apps**. The goal: when the admin console is done and we
move to wiring the mobile app, every contract is already fixed here — nothing
left to design, only to connect.

**Legend:** ✅ endpoint exists & mounted · ⚠️ code exists but **not mounted** ·
❌ missing (needs building). Conventions (envelope, `requireAdmin`, pagination,
errors) are in [`backend-admin-api-spec.md`](backend-admin-api-spec.md).

The admin console side of each feature is **already built and wiring-ready** —
where an endpoint is missing, the control is present-but-inert with a tooltip.

---

## 1. Driver documents

Round-trip: **driver uploads → status `submitted` → admin reviews → approve/
reject → driver sees the outcome.**

| Actor | Method + Path | Status | Notes |
|-------|---------------|--------|-------|
| Driver app | `GET /api/driver/documents` | ✅ | driver reads own docs + statuses |
| Driver app | `POST /api/driver/documents/:type` | ✅ | upload a Cloudinary URL for a doc; sets status → `submitted` |
| Admin | `GET /api/admin/drivers/:id` | ✅ | `documents.<type>.{status,url}` |
| Admin | `PATCH /api/admin/drivers/:id/documents/:type/review` | ✅ | `{status:"approved"|"rejected", reason?}` |
| Admin | `PATCH /api/admin/drivers/:id/approve` | ✅ | approve all + verify |

**Status flow:** `pending` (default) → `submitted` (driver uploaded) →
`approved` / `rejected` (admin). On `rejected`, the driver app should prompt a
re-upload (reason is returned).

**Admin console:** built. Each document tile shows the image + status, and
Approve/Reject stay available even after a decision so an admin can **re-review
and flip** it (the earlier "can't approve — already approved" was just that the
seed doc was already `approved`; the flow needs real driver submissions to show
`submitted` docs).

**Nothing missing here** — the full loop already works; it just needs drivers
using the app to produce `submitted` documents.

---

## 2. Selfie verification (the main gap)

Round-trip: **admin (or the 72h timer) requests a check → driver app is told a
selfie is due → driver submits → it lands in the admin queue → admin approves/
rejects → "last verified" updates.**

| Actor | Method + Path | Status | Notes |
|-------|---------------|--------|-------|
| Driver app | `POST /api/driver/selfie-check` → `submitSelfie` | ⚠️ **code exists, NOT mounted** | body `{photoUrl}`; creates a `SelfieCheck` with status `pending_review` |
| Driver app | `GET /api/driver/selfie-check/status` → `getSelfieStatus` | ⚠️ **code exists, NOT mounted** | returns `{required, hasPending, lastCheckAt, nextDueAt}` — the 72h interval logic is already written |
| Admin | `GET /api/admin/selfie-checks?status=pending_review` | ✅ | the review queue |
| Admin | `PATCH /api/admin/selfie-checks/:id/review` | ✅ | `{status, reason?}` |
| Admin | `POST /api/admin/selfie-checks/request` | ❌ **missing** | admin asks a specific driver to re-verify now |

### 2a. What's needed to close it
1. **Mount the two existing driver endpoints** in `driverRoutes.ts` (they're
   fully implemented in `selfieCheckController.ts`, just never registered):
   ```
   router.post("/selfie-check", protect, restrictTo(DRIVER), submitSelfie);
   router.get("/selfie-check/status", protect, restrictTo(DRIVER), getSelfieStatus);
   ```
   Without this, drivers **cannot submit selfies** — which is why the admin
   queue is always empty.

2. **New admin "request re-verification" endpoint:**
   `POST /api/admin/selfie-checks/request`
   - Auth: admin. Body: `{ "driverId": string (req) }`.
   - Effect: flags the driver so their app's `getSelfieStatus` returns
     `required: true` before the 72h interval, and pushes a notification
     ("Please verify yourself"). Cleanest: add a `SelfieRequest` marker or set a
     `nextDueAt = now` on the driver, plus `createNotification(driverId, …)`.
   - Response 200: `{ "requested": true, "driverId": "…" }`.
   - Errors: `400` bad/missing `driverId`; `404` no such driver.

3. **"Last verified" for the admin** — already available: the admin detail
   endpoint returns `latestSelfie`, and the console already renders
   `lastCheckedAt` (reviewedAt ?? createdAt) + status on the driver's
   **Verification card**.

### 2b. Driver-app side (for the wiring phase)
- On launch / periodically call `GET /api/driver/selfie-check/status`. If
  `required`, open the camera and `POST /api/driver/selfie-check {photoUrl}`
  (upload to Cloudinary client-side first, exactly like documents).
- Show "next check due `nextDueAt`" and block going online if a check is overdue
  (that policy is the app's call; the data is provided).

**Admin console:** built. The driver detail's **Verification card** shows real
last-verified date/time + status, with a **"Request re-verification"** button
that is inert until `POST /selfie-checks/request` exists.

---

## 3. Notifications

Round-trip: **admin composes → backend fans out to recipients → rider/driver
apps receive push + in-app feed → admin sees history.**

| Actor | Method + Path | Status | Notes |
|-------|---------------|--------|-------|
| Rider/Driver app | `GET /api/notifications` | ✅ | own feed |
| Rider/Driver app | `PATCH /api/notifications/read-all`, `/:id/read` | ✅ | mark read |
| Admin | `POST /api/admin/notifications` | ❌ **missing** | compose + broadcast |
| Admin | `GET /api/admin/notifications` | ❌ **missing** | sent history |

### 3a. What's needed
- `POST /api/admin/notifications` — body
  `{ target:"single"|"all_riders"|"all_drivers"|"everyone", userId?, title, body, type? }`.
  Resolve recipients, then **reuse the existing
  `notificationService.createNotification(userId, title, body, type, data)`**
  per recipient (it already writes the `Notification` row **and** fires FCM push
  via `fcmService`). Persist one `NotificationCampaign` row for history. Full
  contract + validation + error cases are in `backend-admin-api-spec.md` §3.
- `GET /api/admin/notifications` — paginated list of `NotificationCampaign`.

### 3b. App side
- Nothing new: the apps already read `/api/notifications` and receive FCM push,
  so broadcasts land automatically once the admin send endpoint writes rows +
  pushes. (Ensure `User.pushToken` is populated by the apps — the field exists.)

**Admin console:** built. Full compose UI (audience, type, title, body, live
preview) is live; the **Send** button and **Recent** history are inert until the
two endpoints above exist. The target/type enums already map 1:1 to the API
values (`NotifTarget.apiValue`, `NotifKind.apiValue`).

---

## 4. Pricing

Round-trip: **admin edits → applies live → rider/driver apps read the new fares
on their next fetch.**

| Actor | Method + Path | Status | Notes |
|-------|---------------|--------|-------|
| Rider/Driver app | `GET /api/pricing/config` | ✅ | public; the exact fares the apps quote |
| Admin | `GET /api/admin/pricing` | ✅ | full config + audit fields |
| Admin | `PUT /api/admin/pricing` | ✅ | applies live |

**This loop is complete.** The admin console edits and saves live; the apps
already read `/api/pricing/config`. For the wiring phase, the apps should fetch
that config at trip-request time (or cache briefly) so an admin change takes
effect on the next quote. `commissionRate` (if added per
`backend-admin-api-spec.md` §4.1) would live in the same config.

---

## 5. Summary — what unblocks the mobile-app wiring

| Feature | Backend work before wiring | App-side work at wiring |
|---------|----------------------------|-------------------------|
| Documents | none — loop complete | upload flow + show reject reason |
| Selfie | **mount 2 existing driver routes**; add `POST /admin/selfie-checks/request` | poll `status`, submit selfie when `required` |
| Notifications | add admin `POST` + `GET` (reuse `createNotification`) | none (already reads feed + push) |
| Pricing | none — loop complete | fetch config at quote time |

Once the ⚠️/❌ items land, the admin console needs only to swap each inert
control for its live call — the models, state and UI are already in place.
