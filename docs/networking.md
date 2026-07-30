# Networking Guide

All HTTP goes through `lib/core/network/` — the single choke point. **No feature
calls Dio directly**; features call a repository → data source → `ApiClient`
(`docs/40` §13–§15).

## Layers

```
data source → ApiClient → Dio (+ interceptors) → frozen v1 API
                 └─ envelope unwrap, query encoding, dedup, offline pre-check,
                    DioException → ApiException
```

- **`ApiClient`** (`api_client.dart`): `get` / `getList` / `getPage` / `post` /
  `postVoid` / `patch` / `delete`. Unwraps the `{success,data,meta}` envelope,
  reads cursor meta at **`meta.pagination`**, applies query conventions (omit null,
  arrays comma-joined, booleans literal), coalesces identical GETs
  (`RequestDeduplicator`), and short-circuits when offline.
- **Data sources supply a decoder** (`Json → Entity`), so the network layer never
  knows a DTO. In M2+, DTOs are generated from `openapi.json` (`packages/qalam_api`)
  and mapped to domain entities in `data/mappers/`.

## Interceptors (order matters — `dio_client.dart`)

1. **AuthInterceptor** — attaches `Authorization: Bearer <access>`; on
   `401 + AUTH_TOKEN_EXPIRED` (outside `/auth/*`) triggers a **single-flight refresh**
   and replays the request once; any other 401 → terminal unauthorized.
2. **RetryInterceptor** — retries **GET** on transport/5xx up to 2× (exp backoff);
   never 4xx, never mutations.
3. **LoggingInterceptor** — redacted, debug-only.

`X-Client: mobile` and `Accept: application/json` are set globally.

## Refresh (`auth_gateway.dart`) — safety-critical

The backend rotates refresh tokens with **family reuse detection**, so refresh is
**single-flight**: concurrent 401s await ONE refresh Future (verified in
`test/core/network/auth_gateway_test.dart`). Rotation atomically replaces both
tokens in secure storage. On failure the session flips to anonymous.

## Errors

`DioException` → `ApiException {code, status, details, requestId}` (never escapes the
data layer) → repositories map to a domain `Failure` via `error_mapper.dart`. Branch
on `error.code`, never `message`. Transport failures use synthetic codes
(`API_OFFLINE`, `API_TIMEOUT`, `API_NETWORK_ERROR`, …). See
`test/core/error/error_mapper_test.dart` and `test/core/network/api_client_test.dart`.

## Uploads (M3+)

Multipart to `POST /profile/avatar|cover`, `POST /pieces/:id/cover`, field `file`,
never set `Content-Type`. Response is a storage `{ key }` → build the URL via
`MediaUrlBuilder`. Uploads bypass the refresh interceptor. There is **no
presigned-URL flow in `v1`**.
