import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookapp_customer/app/providers/connectivity_provider.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isChecking = false;

  Future<void> _retryConnection() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      await context.read<ConnectivityProvider>().refreshNow();
      if (!mounted) return;
      final online = context.read<ConnectivityProvider>().isOnline;
      if (online) {
        Navigator.of(context).maybePop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Still no internet connection')),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                "No Internet Connection",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("Please check your network settings"),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isChecking ? null : _retryConnection,
                child: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
