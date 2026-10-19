import 'package:flutter/material.dart';

import 'package:blood_donation_app/features/blood_request/presentation/pages/my_requests_tab.dart';
import 'package:blood_donation_app/features/blood_request/presentation/pages/post_request_page.dart';
import 'package:blood_donation_app/features/blood_request/presentation/pages/request_feed_tab.dart';
import 'package:blood_donation_app/features/donor_profile/domain/entities/user_profile.dart';
import 'package:blood_donation_app/features/donor_profile/presentation/pages/profile_tab.dart';
import 'package:blood_donation_app/features/donor_search/presentation/pages/donor_search_tab.dart';

/// Home for a user with a completed profile: four tabs (requests, my
/// requests, find donors, profile) plus the "Request blood" button.
///
/// Lives at app level because it is the one place that knows several
/// features; each feature's pages know only their own.
///
/// Only the selected tab is built, so switching tabs reloads its data:
/// slightly more reads, but never a stale list, and it keeps free-tier
/// usage predictable.
class HomeShell extends StatefulWidget {
  const HomeShell({required this.profile, required this.onSignOut, super.key});

  final UserProfile profile;
  final VoidCallback onSignOut;

  static const Key signOutButtonKey = Key('home.signOut');
  static const Key postRequestButtonKey = Key('home.postRequest');
  static const Key requestsTabKey = Key('home.tab.requests');
  static const Key myRequestsTabKey = Key('home.tab.myRequests');
  static const Key donorsTabKey = Key('home.tab.donors');
  static const Key profileTabKey = Key('home.tab.profile');

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const List<String> _titles = [
    'Blood requests',
    'My requests',
    'Find donors',
    'Profile',
  ];

  int _index = 0;

  Future<void> _postRequest() async {
    final posted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PostRequestPage(profile: widget.profile),
      ),
    );
    // Show the new request where the user can manage it.
    if (posted == true && mounted) setState(() => _index = 1);
  }

  Widget _body() {
    return switch (_index) {
      0 => RequestFeedTab(profile: widget.profile),
      1 => MyRequestsTab(profile: widget.profile),
      2 => DonorSearchTab(profile: widget.profile, onPostRequest: _postRequest),
      _ => ProfileTab(profile: widget.profile),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            key: HomeShell.signOutButtonKey,
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: widget.onSignOut,
          ),
        ],
      ),
      body: _body(),
      floatingActionButton: _index <= 1
          ? FloatingActionButton.extended(
              key: HomeShell.postRequestButtonKey,
              onPressed: _postRequest,
              icon: const Icon(Icons.add),
              label: const Text('Request blood'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            key: HomeShell.requestsTabKey,
            icon: Icon(Icons.bloodtype_outlined),
            selectedIcon: Icon(Icons.bloodtype),
            label: 'Requests',
          ),
          NavigationDestination(
            key: HomeShell.myRequestsTabKey,
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'Mine',
          ),
          NavigationDestination(
            key: HomeShell.donorsTabKey,
            icon: Icon(Icons.search),
            label: 'Donors',
          ),
          NavigationDestination(
            key: HomeShell.profileTabKey,
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
