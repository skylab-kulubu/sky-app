import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';

class ShortcutsSection extends StatelessWidget {
  const ShortcutsSection({super.key});

  // TODO icon ve isimleri gerçek verilerle değiştir

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPaddings.mainPaddingAll,
      decoration: BoxDecoration(
        color: Colors.grey[850], // TODO constant yap
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Container(
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent: 80.0, // TODO constant yap
                crossAxisCount: 4,
                mainAxisSpacing: 24.0, // TODO constant yap
                crossAxisSpacing: 16.0, // TODO constant yap
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // TODO navigate to page
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.blue, // TODO constant yap
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ), // TODO constant yap
                        ),
                        child: Icon(
                          Icons.star, // TODO change icon
                          color: Colors.white, // TODO constant yap
                        ), // TODO REAL ICONS
                      ),
                      SizedBox(height: 8.0), // TODO constant yap
                      Text('Kısayol ${index + 1}'), // TODO REAL NAMES
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12.0),
          ElevatedButton(
            onPressed: () {
              // TODO navigate to all shortcuts
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.scaffoldBackgroundColor, // TODO constant yap
              foregroundColor: Colors.white, // TODO constant yap
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // TODO constant yap
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit), // TODO constant yap
                SizedBox(width: 12.0), // TODO constant yap
                Text('Kısayolları Düzenle'),
              ],
            ), // TODO constant yap
          ),
        ],
      ),
    );
  }
}
