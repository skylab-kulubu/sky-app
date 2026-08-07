import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/features/profile/data/models/certificate.dart';
import 'package:sky_app/features/profile/data/services/certificate_service.dart';
import 'package:sky_app/features/profile/presentation/widgets/certificate_tile.dart';

part 'certificates_pagemodel.dart';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends CertificatesPagemodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sertifikalar'),
        leading: IconButton(
          icon: const AppIcon(AppIcons.arrowBack),
          onPressed: () => context.pop(),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: context.accentColor))
          : listOfCert.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Maalesef sertifikan yok ama bir eğitime katılarak sahip olabilirsin!',
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ),
            )
          : ListView(
              padding: AppPaddings.mainPaddingAll,
              children: [
                TileGroup(
                  children: [
                    for (final cert in listOfCert)
                      CertificateTile(certificate: cert),
                  ],
                ),
              ],
            ),
    );
  }
}
