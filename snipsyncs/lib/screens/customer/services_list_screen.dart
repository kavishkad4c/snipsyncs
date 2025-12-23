import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../widgets/service_card.dart';
import '../../providers/service_provider.dart';
import 'service_detail_screen.dart';

class ServicesListScreen extends StatefulWidget {
  final String? salonId;
  final String? salonName;

  const ServicesListScreen({super.key, this.salonId, this.salonName});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Load services when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      serviceProvider.loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.salonName ?? 'Services'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ServiceProvider>(
        builder: (context, serviceProvider, child) {
          if (serviceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (serviceProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${serviceProvider.error}'),
                  ElevatedButton(
                    onPressed: serviceProvider.loadServices,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          final allServices = serviceProvider.services;
          final filteredServices = _selectedCategory == 'All' 
              ? allServices 
              : allServices.where((s) => s.category == _selectedCategory).toList();
          
          final categories = allServices
              .map((s) => s.category)
              .where((category) => category != null)
              .map((category) => category!)
              .toSet()
              .toList()
                ..insert(0, 'All');
          
          if (allServices.isEmpty) {
            return const Center(
              child: Text('No services available'),
            );
          }
          
          return Column(
            children: [
              // Categories filter
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : 'All';
                          });
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: serviceProvider.loadServices,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
                      return ServiceCard(
                        service: service,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServiceDetailScreen(service: service),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}