import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: const Text('User Name'),
                            subtitle: Text(user.name),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.email_outlined),
                            title: const Text('Email'),
                            subtitle: Text(user.email),
                            trailing: user.emailVerified 
                                ? const Icon(Icons.verified, color: Colors.green)
                                : const Icon(Icons.pending, color: Colors.orange),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.phone_outlined),
                            title: const Text('Phone Number'),
                            subtitle: Text(user.phone),
                            trailing: user.phoneVerified 
                                ? const Icon(Icons.verified, color: Colors.green)
                                : const Icon(Icons.pending, color: Colors.orange),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.local_shipping),
                            title: const Text('Connected Rover Key'),
                            subtitle: Text(user.roverKey, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
