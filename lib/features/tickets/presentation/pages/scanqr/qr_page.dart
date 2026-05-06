import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/features/tickets/data/models/event_day_model.dart';
import 'package:sky_app/features/tickets/data/services/check_in_service.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({super.key});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  final CheckInService _checkInService = CheckInService();
  final MobileScannerController _scannerController = MobileScannerController(
    autoStart: false,
  );

  List<EventDayModel> _eventDays = [];
  EventDayModel? _selectedEventDay;
  String? _scannedTicketId;
  bool _isScanning = false;
  bool _isLoading = false;
  bool? _checkInSuccess;

  @override
  void initState() {
    super.initState();
    _loadEventDays();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _loadEventDays() async {
    final days = await _checkInService.fetchEventDays();
    if (!mounted) return;
    setState(() {
      _eventDays = days;
      _selectedEventDay = days.isNotEmpty ? days.first : null;
    });
  }

  void _startScanning() {
    setState(() => _isScanning = true);
    _scannerController.start();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null) return;

    _scannerController.stop();
    setState(() {
      _isScanning = false;
      _scannedTicketId = rawValue;
    });
    _performCheckIn(rawValue);
  }

  Future<void> _performCheckIn(String ticketId) async {
    final eventDayId = _selectedEventDay?.eventDayId;
    if (eventDayId == null) return;

    setState(() => _isLoading = true);
    final success = await _checkInService.checkIn(
      ticketId: ticketId,
      eventDayId: eventDayId,
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _checkInSuccess = success;
    });
  }

  void _resetScan() {
    setState(() {
      _scannedTicketId = null;
      _isScanning = false;
      _checkInSuccess = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          children: [
            _ActiveSessionContainer(
              selectedEventDay: _selectedEventDay,
              eventDays: _eventDays,
              onDaySelected: (day) => setState(() => _selectedEventDay = day),
            ),
            SizedBox(height: AppSizes.bigSpace),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadiuses.cardRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _onDetect,
                    ),
                    if (!_isScanning && _scannedTicketId == null)
                      _StartScanOverlay(onStart: _startScanning),
                    if (_isLoading)
                      const _LoadingOverlay(),
                    if (_scannedTicketId != null && !_isLoading)
                      _ResultOverlay(
                        success: _checkInSuccess ?? false,
                        onReset: _resetScan,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartScanOverlay extends StatelessWidget {
  const _StartScanOverlay({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_scanner, size: 64, color: Colors.white),
            SizedBox(height: AppSizes.midSpace),
            Text(
              'Kamera hazır',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            SizedBox(height: AppSizes.bigSpace),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Taramaya Başla'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({required this.success, required this.onReset});

  final bool success;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.cancel,
              size: 72,
              color: success ? Colors.green : Colors.red,
            ),
            SizedBox(height: AppSizes.midSpace),
            Text(
              success ? 'Check-in Başarılı' : 'Check-in Başarısız',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSizes.bigSpace),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Tekrar Tara',
                style: TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveSessionContainer extends StatelessWidget {
  const _ActiveSessionContainer({
    required this.selectedEventDay,
    required this.eventDays,
    required this.onDaySelected,
  });

  final EventDayModel? selectedEventDay;
  final List<EventDayModel> eventDays;
  final ValueChanged<EventDayModel> onDaySelected;

  void _showDayPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadiuses.cardRadius),
        ),
      ),
      builder: (context) => ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: eventDays.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, index) {
          final day = eventDays[index];
          final isSelected = day.id == selectedEventDay?.id;
          return ListTile(
            title: Text(day.name.isNotEmpty ? day.name : '${index + 1}. Gün'),
            subtitle: day.formattedDate.isNotEmpty
                ? Text(day.formattedDate)
                : null,
            trailing: isSelected
                ? Icon(Icons.check_circle, color: AppColors.primaryColor)
                : null,
            onTap: () {
              onDaySelected(day);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayLabel = selectedEventDay != null
        ? (selectedEventDay!.name.isNotEmpty
            ? selectedEventDay!.name
            : selectedEventDay!.formattedDate)
        : '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(AppRadiuses.cardRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Aktif Oturum',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: Colors.white),
          ),
          SizedBox(width: AppSizes.midSpace),
          Text(
            dayLabel,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: eventDays.isEmpty ? null : () => _showDayPicker(context),
            child: Text(
              'Oturumu Değiştir',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

AppBar _buildAppBar(BuildContext context) => AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  titleSpacing: 12,
  title: Text(
    "Bilet Tarayıcı",
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
  ),
);
