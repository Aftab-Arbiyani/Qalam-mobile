/// Common typedefs used across layers.
library;

/// A decoded JSON object (the shape `dio` yields and mappers consume).
typedef Json = Map<String, dynamic>;

/// A decoded JSON array.
typedef JsonList = List<dynamic>;

/// Decodes a raw JSON object into a typed value `T` (used by `ApiClient` to keep
/// the generic `data` payload out of the network layer — the caller owns
/// deserialization, docs/40 §18).
typedef JsonDecoder<T> = T Function(Json json);

/// The unit type — a `Result` payload for operations that succeed without a
/// meaningful value (e.g. `forgot-password`, `verify-email`). Modelled as the
/// empty record so `Result<Unit>` composes with the sealed `Result` type without a
/// bespoke sentinel class.
typedef Unit = ();

/// The single [Unit] value.
const Unit unit = ();
