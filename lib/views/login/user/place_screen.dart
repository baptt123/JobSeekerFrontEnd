import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/place_view_model.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({Key? key}) : super(key: key);

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  final TextEditingController _controller = TextEditingController();

  void _onSearch() {
    context.read<PlacesViewModel>().findNearbyCompanies(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm Công Ty Lân Cận (Geoapify)'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nhập địa điểm hoặc khu vực',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _onSearch,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Tìm kiếm'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<PlacesViewModel>(
                builder: (context, vm, _) {
                  switch (vm.state) {
                    case ViewState.loading:
                      return const Center(child: CircularProgressIndicator());
                    case ViewState.error:
                      return Center(
                        child: Text(
                          vm.errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      );
                    case ViewState.loaded:
                      return ListView.builder(
                        itemCount: vm.places.length,
                        itemBuilder: (context, index) {
                          final p = vm.places[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.business),
                              title: Text(p.name),
                              subtitle: Text(p.address),
                            ),
                          );
                        },
                      );
                    case ViewState.initial:
                    default:
                      return const Center(
                        child: Text(
                          'Nhập một địa điểm để bắt đầu tìm kiếm.',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
