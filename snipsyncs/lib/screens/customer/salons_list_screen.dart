import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../models/salon_model.dart';
import '../../providers/salon_provider.dart';
import 'services_list_screen.dart';

class SalonsListScreen extends StatefulWidget {
  const SalonsListScreen({super.key});

  @override
  State<SalonsListScreen> createState() => _SalonsListScreenState();
}

class _SalonsListScreenState extends State<SalonsListScreen> {
  @override
  void initState() {
    super.initState();
    // Load salons when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final salonProvider = Provider.of<SalonProvider>(context, listen: false);
      salonProvider.loadSalons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Salons'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<SalonProvider>(
        builder: (context, salonProvider, child) {
          if (salonProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (salonProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${salonProvider.error}'),
                  ElevatedButton(
                    onPressed: salonProvider.loadSalons,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          final salons = salonProvider.salons;
          
          if (salons.isEmpty) {
            return const Center(
              child: Text('No salons available'),
            );
          }
          
          return RefreshIndicator(
            onRefresh: salonProvider.loadSalons,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: salons.length,
              itemBuilder: (context, index) {
                final salon = salons[index];
                return _SalonCard(
                  salon: salon,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServicesListScreen(salonId: salon.id, salonName: salon.name),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SalonCard extends StatelessWidget {
  final SalonModel salon;
  final VoidCallback onTap;

  const _SalonCard({required this.salon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                salon.image ?? AppConstants.salonImage1,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          salon.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              salon.rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    salon.description ?? 'No description available',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          salon.address,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(salon.phone, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Working hours would be loaded from database in a real implementation
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      const Text('Open: 9:00 AM - 8:00 PM', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}