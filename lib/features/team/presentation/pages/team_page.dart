import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/features/team/presentation/widgets/person_tag.dart';
import 'package:sky_app/features/team/presentation/widgets/section_expansion_tile.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final List<PersonTag> personTags = [
    PersonTag(title: 'UI/UX Tasarımcı'),
    PersonTag(title: 'Öğrenme Ekibi'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: AppPaddings.mainPaddingAll,
          child: Column(
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    'M',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: AppColors.blue,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text('MOBILAB', style: context.textTheme.headlineSmall),
              ), //TODO  şimdilik sabit veri çekmiyo

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 6,
                  children: personTags,
                ),
              ),

              SizedBox(height: 16),
              SectionExpansionTile(
                title: 'Duyurular',
                color: AppColors.red,
                icon: AppIcons.announcement,
              ),
              SectionExpansionTile(
                title: 'Görevler',
                color: AppColors.blue,
                icon: AppIcons.task,
              ),
              SectionExpansionTile(
                title: 'Proje Atama',
                color: AppColors.green,
                icon: AppIcons.project,
              ),
              SectionExpansionTile(
                title: 'Eğitimler',
                color: AppColors.darkPurple,
                icon: AppIcons.education,
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
