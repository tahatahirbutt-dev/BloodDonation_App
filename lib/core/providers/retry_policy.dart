/// Riverpod 3 retries a failing provider up to 10 times with backoff by
/// default. For this app that is wrong: a typed failure ("No connection")
/// should reach the screen immediately, with an explicit Retry button the
/// user controls, not after a minute of silent retries behind a spinner.
///
/// Pass to `ProviderScope(retry: noAutoRetry)`.
Duration? noAutoRetry(int retryCount, Object error) => null;
