import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:trace_app_3c/screens/login.dart';
import 'package:trace_app_3c/screens/register_client.dart';
import 'package:trace_app_3c/screens/register_establishment.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'traceIT',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const Gap(12),
              Text(
                'MAD 2 Assignment 4 cabico',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Gap(12),
              ElevatedButton(
                onPressed: () => openScreen(context, LoginScreen()),
                child: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 1, 119, 244),
                  foregroundColor: Colors.white,
                ),
              ),
              const Gap(12),
              ElevatedButton(
                  onPressed: () => openScreen(context, RegisterClientScreen()),
                  child: const Text('Register as Client')),
              const Gap(12),
              ElevatedButton(
                  onPressed: () =>
                      openScreen(context, RegisterEstablishmentScreen()),
                  child: const Text('Register as Establishment')),
            ],
          ),
        ),
      ),
    );
  }
}
