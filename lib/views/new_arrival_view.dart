import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/jewelry_viewmodel.dart';
import 'components/jewelry_item_card.dart';

class NewArrivalView extends StatefulWidget {
  const NewArrivalView({Key? key}) : super(key: key);

  @override
  State<NewArrivalView> createState() => _NewArrivalViewState();
}

class _NewArrivalViewState extends State<NewArrivalView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JewelryViewModel>(context, listen: false).fetchNewArrivals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Arrivals'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Consumer<JewelryViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoadingArrivals) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryButton));
          }
          if (vm.newArrivals.isEmpty) {
            return Center(child: Text("No new arrivals found.", style: GoogleFonts.poppins()));
          }

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: vm.newArrivals.length,
            itemBuilder: (context, index) {
              final item = vm.newArrivals[index];
              return JewelryItemCard(item: item);
            },
          );
        },
      ),
    );
  }
}



