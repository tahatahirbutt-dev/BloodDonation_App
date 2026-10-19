import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blood_donation_app/core/error/failure.dart';
import 'package:blood_donation_app/core/error/result.dart';

/// Turns whatever an `AsyncValue` carries as its error into a [Failure]
/// the UI can show. Notifiers put `Failure`s into `AsyncError`, but
/// Anything else is a bug we did not anticipate and becomes a generic message,
/// never a crash.
Failure failureFromError(Object error) {
  if (error is Failure) return error;
  return const UnexpectedFailure();
}

/// The [Failure] inside an errored `AsyncValue`, or null.
Failure? failureOf<T>(AsyncValue<T> value) {
  final error = value.error;
  return error == null ? null : failureFromError(error);
}

/// Message for a specific text field, when the failure targets it.
String? fieldErrorFor(Failure? failure, String field) {
  return failure is ValidationFailure && failure.field == field
      ? failure.message
      : null;
}

/// The failure to show in a banner: everything except validation errors
/// that already appear under one of [inlineFields].
Failure? bannerFailure(Failure? failure, Set<String> inlineFields) {
  if (failure is ValidationFailure && inlineFields.contains(failure.field)) {
    return null;
  }
  return failure;
}

/// Converts a use-case [Result] into the `AsyncValue<void>` that
/// mutation-style notifiers expose: success becomes `AsyncData`, failure
/// becomes `AsyncError` carrying the typed [Failure].
AsyncValue<void> asyncVoidFromResult<T>(Result<T> result) {
  return switch (result) {
    Success<T>() => const AsyncData<void>(null),
    Err<T>(:final failure) => AsyncError<void>(failure, StackTrace.current),
  };
}
