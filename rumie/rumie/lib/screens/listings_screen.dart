import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/listing_card.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  String selectedType = 'All';

  final List<String> types = const [
    'All',
    'Apartment',
    'House',
    'Condo',
    'Room',
    'Duplex',
    'Studio',
  ];

  final List<Map<String, dynamic>> listings = const [
    {
      'title': 'Bright private room near campus',
      'type': 'Room',
      'location': 'Westwood, Los Angeles',
      'rent': 1250,
      'bedsBaths': '1 bed / shared bath',
      'availableDate': 'June 1',
    },
    {
      'title': 'Pastel apartment with shared kitchen',
      'type': 'Apartment',
      'location': 'Koreatown, Los Angeles',
      'rent': 1800,
      'bedsBaths': '2 bed / 1 bath',
      'availableDate': 'July 10',
    },
    {
      'title': 'Quiet condo with study space',
      'type': 'Condo',
      'location': 'Pasadena, CA',
      'rent': 2100,
      'bedsBaths': '2 bed / 2 bath',
      'availableDate': 'Now',
    },
    {
      'title': 'Duplex room with backyard',
      'type': 'Duplex',
      'location': 'El Sereno, Los Angeles',
      'rent': 1450,
      'bedsBaths': '1 bed / 1 bath',
      'availableDate': 'August 1',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final visibleListings = selectedType == 'All'
        ? listings
        : listings.where((listing) => listing['type'] == selectedType).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 120,
              right: -35,
              child: _blob(AppColors.softPink, 120),
            ),
            Positioned(
              bottom: 160,
              left: -45,
              child: _blob(AppColors.softBlue, 140),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildTypeFilter(),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 120),
                    itemCount: visibleListings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final listing = visibleListings[index];

                      return ListingCard(
                        title: listing['title'],
                        type: listing['type'],
                        location: listing['location'],
                        rent: listing['rent'],
                        bedsBaths: listing['bedsBaths'],
                        availableDate: listing['availableDate'],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: AppColors.darkText,
            width: 3,
          ),
        ),
        onPressed: () {},
        icon: const Icon(Icons.add_home_work_outlined),
        label: const Text(
          'Post Listing',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        children: [
          const Text(
            'Listings',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.yellow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkText, width: 3),
            ),
            child: const Text(
              'Landlord',
              style: TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final type = types[index];
          final selected = selectedType == type;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedType = type;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.purple : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkText, width: 3),
              ),
              child: Text(
                type,
                style: const TextStyle(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
