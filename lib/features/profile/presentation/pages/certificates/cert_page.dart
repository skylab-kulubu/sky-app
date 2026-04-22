import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/features/profile/data/models/cert_model.dart';
import 'package:sky_app/features/profile/presentation/widgets/cert_item.dart';

part 'cert_pagemodel.dart';

class CertPage extends StatefulWidget {
  const CertPage({super.key});

  @override
  State<CertPage> createState() => _CertPageState();
}

class _CertPageState extends CertPagemodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: appBar(),
      body: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            subtitleText(),
            const SizedBox(height: 16),
            certificatesListContainer(),
          ],
        ),
      ),
    );
  }

  AppBar appBar() => AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    titleSpacing: 12,
    title: const Text(
      'Sertifikalar',
      style: TextStyle(
        color: AppColors.textWhite,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget subtitleText() => const Text(
    'Bootcamp ve eğitimlerden kazanılan sertifikalar.',
    style: TextStyle(color: AppColors.textGrey, fontSize: 14),
  );

  Widget certificatesListContainer() => Expanded(
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadiuses.containerBorderRadius,
      ),
      child: ListView.separated(
        itemCount: listOfCert.length,

        separatorBuilder: (context, index) => const Divider(
          color: AppColors.dividerColor,
          height: 1,
          thickness: 1,
        ),
        itemBuilder: (context, index) {
          return CertItem(certificate: listOfCert[index]);
        },
      ),
    ),
  );
}
