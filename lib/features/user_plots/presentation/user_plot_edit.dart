// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPlotEditScreen extends ConsumerStatefulWidget {
  const UserPlotEditScreen({super.key});

  @override
  _UserPlotEditScreenState createState() => _UserPlotEditScreenState();
}

class _UserPlotEditScreenState extends ConsumerState<UserPlotEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Plot'),
      ),
      body: const Center(
        child: Text('Edit Plot'),
      ),
    );
  }
}
