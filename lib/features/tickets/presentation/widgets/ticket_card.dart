import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';

class TicketCard extends StatelessWidget {
  final String eventName;
  final String location;
  final String date;
  final String time;
  final String ticketNo;
  final String holderName;
  final bool isActive;

  const TicketCard({
    super.key,
    required this.eventName,
    required this.location,
    required this.date,
    required this.time,
    required this.ticketNo,
    required this.holderName,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadiuses.cardBorderRadius,
      child: Column(
        children: [
          _Header(eventName: eventName, location: location, isActive: isActive),
          _Details(date: date, time: time, ticketNo: ticketNo),
          const Divider(
            color: AppColors.dividerColor,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          _Footer(holderName: holderName),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String eventName;
  final String location;
  final bool isActive;

  const _Header({
    required this.eventName,
    required this.location,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: isActive ? AppColors.primaryColor : AppColors.buttonBackground,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusBadge(isActive: isActive),
          const SizedBox(height: 10),
          Text(
            eventName.toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.textWhite70,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textWhite70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.green : AppColors.textGray,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Aktif Bilet' : 'Geçmiş Bilet',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.textWhite),
          ),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final String date;
  final String time;
  final String ticketNo;

  const _Details({
    required this.date,
    required this.time,
    required this.ticketNo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailItem(label: 'TARİH', value: date),
                const SizedBox(height: 12),
                _DetailItem(label: 'SAAT', value: time),
                const SizedBox(height: 12),
                _DetailItem(label: 'BİLET NO', value: ticketNo),
              ],
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadiuses.containerRadius),
            ),
            child: const Center(
              child: Icon(Icons.qr_code_2, size: 80, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textGray,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final String holderName;

  const _Footer({required this.holderName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppColors.textGray, size: 18),
          const SizedBox(width: 8),
          Text(
            holderName,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textWhite70),
          ),
        ],
      ),
    );
  }
}
