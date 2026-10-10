# Trip Map & Checkpoints — Backend Spec (MVP)

The app shows the whole trip on one map:

- **Overview:** every day's route as a faded polyline, one "Day N" marker per day, and a dashed line linking the last checkpoint of a day to the first of the next.
- **Day selected:** that day's route is highlighted, its checkpoints appear as numbered markers, and the camera zooms to the day.
- **Single-day trips** open directly on the day view.

The app draws everything locally. The backend only has to return clean, ordered data.

---

## 1. Add checkpoint (exists)

`POST /trips/{tripId}/days/{dayNumber}/checkpoints`

```json
{
  "title": "Palazzo dell'Immacolatella",
  "address": "Imbarco Grimaldi Lines per Cagliari",
  "lat": 40.840872,
  "lng": 14.26114,
  "entered_at": "2026-05-07T10:30:00Z",
  "exited_at": "2026-05-07T11:00:00Z"
}
```

The response returns the created checkpoint, using the same checkpoint object as in section 2. The app uses it to update the map without reloading.

Requests:
- Re-number `display_order` by `entered_at` within the day, so a checkpoint added later for an earlier time lands in the right place.
- Reject `exited_at <= entered_at` with a 400 error and a readable message.
- Return `400` if `dayNumber` is outside the trip's days.
- Add `source` (`MANUAL` | `AUTO`) to the checkpoint. This endpoint always stores `MANUAL`; automatic check-ins will use `AUTO` later.

---

## 2. Trip map (new)

`GET /trips/{tripId}/map`

```json
{
  "success": true,
  "message": "Trip map fetched.",
  "data": {
    "trip_id": "cmuxwqadw0000bsvlntlr3xk8",
    "bounds": { "north": 40.89, "south": 40.55, "east": 14.61, "west": 14.20 },
    "days": [
      {
        "day_number": 1,
        "date": "2026-05-07",
        "anchor": {
          "lat": 40.8282,
          "lng": 14.2475,
          "checkpoint_id": "cmv26l7du0002jgvlclbyrjun",
          "place_name": "Castel dell'Ovo"
        },
        "bounds": { "north": 40.89, "south": 40.82, "east": 14.29, "west": 14.24 },
        "route_polyline": null,
        "distance_meters": 12450,
        "checkpoints": [
          {
            "id": "cmv26l7du0002jgvlclbyrjun",
            "title": "Palazzo dell'Immacolatella",
            "address": "Imbarco Grimaldi Lines per Cagliari",
            "lat": 40.840872,
            "lng": 14.26114,
            "entered_at": "2026-05-07T10:30:00.000Z",
            "exited_at": "2026-05-07T11:00:00.000Z",
            "duration_minutes": 30,
            "display_order": 1,
            "status": "COMPLETED",
            "source": "MANUAL",
            "photo_count": 4
          }
        ]
      },
      {
        "day_number": 2,
        "date": "2026-05-08",
        "anchor": null,
        "bounds": null,
        "route_polyline": null,
        "distance_meters": 0,
        "checkpoints": []
      }
    ]
  }
}
```

### Field rules

| Field | Rule |
|---|---|
| `days` | **Every** day of the trip, ordered by `day_number`, including days without checkpoints. |
| `checkpoints` | Sorted by `display_order`, which follows `entered_at`. The checkpoint fields match the POST response. |
| `anchor` | The day's map marker: the checkpoint with the **longest `duration_minutes`**; on a tie, the one with more photos, then the earlier one. `null` when the day has no checkpoints. Don't use the centre of the checkpoints, because it can fall on water or a place the user never visited. |
| `bounds` (day) | Min/max lat/lng of the day's checkpoints (and route points, if any). `null` when the day is empty. |
| `bounds` (trip) | Min/max over all days. |
| `route_polyline` | Optional. A Google **encoded polyline** of the actual travelled path, once location tracking exists; simplify it to at most about 300 points per day. Send `null` until then, and the app draws straight lines between checkpoints. |
| `distance_meters` | Optional. The sum of distances along the route, or between checkpoints. |
| `photo_count` | Optional. Number of finalized photos linked to the checkpoint. |
| Times | ISO-8601 UTC. `date` is the local trip day (`YYYY-MM-DD`). |

### Notes
- Compute `anchor`, `bounds` and `display_order` when a checkpoint is created, updated or deleted, not on every GET.
- Store `address` (and, later, a reverse-geocoded `place_name`) **once per checkpoint**. Don't call Google Geocoding or Directions APIs when reading the map; those are billed per request.
- Keep this endpoint separate from `GET /trips/{id}` so the details response stays small.

---

## 3. Later (automatic check-ins)

These aren't needed for the MVP, but plan the schema for them:
- `POST /trips/{tripId}/locations`: batched location pings (`lat`, `lng`, `accuracy`, `recorded_at`) from the app.
- Server-side stay detection: if the user stays within about 150 m for more than 10–15 minutes, create a checkpoint with `source = AUTO`.
- Build `route_polyline` per day from the pings, simplified.
- `PATCH` and `DELETE /trips/{tripId}/checkpoints/{id}`, so users can rename or remove automatic checkpoints.
