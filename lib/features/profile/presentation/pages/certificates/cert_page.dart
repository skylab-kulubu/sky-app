import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
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
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text('Sertifikalar'),
        leading: IconButton(
          icon: const AppIcon(AppIcons.arrowBack),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
      ),
    );
  }

  Widget subtitleText() => Text(
    'Bootcamp ve eğitimlerden kazanılan sertifikalar.',
    style: TextStyle(color: context.textSecondary, fontSize: 14),
  );

  Widget certificatesListContainer() => Container(
    decoration: BoxDecoration(
      color: context.tileColor,
      borderRadius: AppRadiuses.containerBorderRadius,
    ),
    child: ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listOfCert.length,
      separatorBuilder: (context, index) =>
          Divider(color: context.dividerColor, height: 1, thickness: 1),
      itemBuilder: (context, index) {
        return CertItem(certificate: listOfCert[index]);
      },
    ),
  );
}
