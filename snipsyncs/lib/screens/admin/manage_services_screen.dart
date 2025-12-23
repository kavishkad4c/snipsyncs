import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import 'add_service_screen.dart';
import 'edit_service_screen.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      serviceProvider.loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Manage Services'),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: serviceProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : serviceProvider.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${serviceProvider.error}',
                            style: const TextStyle(color: AppColors.error),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: serviceProvider.loadServices,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: serviceProvider.loadServices,
                      child: CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            pinned: true,
                            backgroundColor: Colors.white,
                            expandedHeight: 120,
                            flexibleSpace: FlexibleSpaceBar(
                              title: const Text('Services'),
                              background: Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.gradient1,
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'All Services',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const AddServiceScreen(),
                                            ),
                                          );
                                          if (result == true) {
                                            serviceProvider.loadServices();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Add Service'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  if (serviceProvider.services.isEmpty)
                                    const Center(
                                      child: Text(
                                        'No services available. Add your first service!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    )
                                  else
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        childAspectRatio: 3,
                                        mainAxisSpacing: 16,
                                      ),
                                      itemCount: serviceProvider.services.length,
                                      itemBuilder: (context, index) {
                                        final service = serviceProvider.services[index];
                                        return _ServiceCard(
                                          service: service,
                                          onEdit: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => EditServiceScreen(service: service),
                                              ),
                                            );
                                            if (result == true) {
                                              serviceProvider.loadServices();
                                            }
                                          },
                                          onDelete: () {
                                            _confirmDelete(context, service, serviceProvider);
                                          },
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ServiceModel service, ServiceProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Service'),
          content: Text('Are you sure you want to delete "${service.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                provider.deleteService(service.id);
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Handle null image with a default placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: service.image != null && service.image!.isNotEmpty
                  ? Image.network(
                      service.image!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.image, color: AppColors.primary),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.image, color: AppColors.primary),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${service.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${service.duration} min',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}