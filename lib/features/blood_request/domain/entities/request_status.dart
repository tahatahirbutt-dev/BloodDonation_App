/// Lifecycle of a blood request. Only the requester moves it, and only
/// out of [open] (the security rules enforce the same transitions).
///
/// Persist [name], never [label].
enum RequestStatus {
  open('Open'),
  fulfilled('Fulfilled'),
  cancelled('Cancelled');

  const RequestStatus(this.label);

  final String label;
}
