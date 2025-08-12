import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/no_result_view_model.dart';


class NoResultsScreen extends StatelessWidget {
  const NoResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var vm = Provider.of<NoResultsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 18),
            TextField(
              decoration: InputDecoration(
                hintText: 'Design',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: vm.updateQuery,
            ),
            const SizedBox(height: 46),
            Icon(Icons.search_off, size: 80, color: Colors.orangeAccent),
            const SizedBox(height: 18),
            const Text('No results found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21)),
            const SizedBox(height: 12),
            const Text(
              'The search could not be found, please check spelling or write another word.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}
