import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blood_donation_app/core/observability/error_reporter_provider.dart';

import 'phone_dialer.dart';
import 'url_launcher_phone_dialer.dart';

part 'phone_dialer_provider.g.dart';

/// Tests override this with a recording fake.
@Riverpod(keepAlive: true)
PhoneDialer phoneDialer(Ref ref) =>
    UrlLauncherPhoneDialer(reporter: ref.watch(errorReporterProvider));
