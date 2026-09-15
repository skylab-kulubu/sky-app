part of 'account_page.dart';

abstract class AccountPagemodel extends State<AccountPage> {
  static const String _email = 'info@yildizskylab.com';
  static const String _deleteSubject = 'Hesap Silme Talebi';

  void onLinkedinTap(String url) {
    WebviewService.openLink(
      context,
      LinkItem(
        name: 'LinkedIn',
        description: '',
        icon: AppIcons.linkedin,
        color: AppColors.blue,
        // Kayıt şemasız gelebiliyor; `Uri.parse` o hâlde bunu göreli yol
        // sayar ve webview boş açılır.
        url: url.startsWith('http') ? url : 'https://$url',
      ),
    );
  }

  /// Onay alıp mail uygulamasını hazır silme talebiyle açar.
  ///
  /// Backend'de hesap silme ucu yok; talep kulübe e-postayla gidiyor. Gövdeye
  /// hesabı tanıtan bilgiler ekleniyor ki talep eşleştirilebilsin. Mail
  /// uygulaması yoksa adres panoya kopyalanıyor.
  Future<void> onDeleteAccountTap(User user) async {
    final confirmed = await _confirmDelete();
    if (confirmed != true || !mounted) return;

    final details = [
      'Ad: ${user.name}',
      if (user.usernameDisplay.isNotEmpty)
        'Kullanıcı adı: ${user.usernameDisplay}',
      if (user.email.isNotEmpty) 'E-posta: ${user.email}',
      if (user.skyNumber.isNotEmpty) 'SKY numarası: ${user.skyNumber}',
    ].join('\n');
    final body =
        'SKY LAB hesabımın ve üyelik bilgilerimin silinmesini istiyorum.'
        '\n\n$details';

    // `queryParameters` boşlukları `+` yapıyor; parçalar elle kodlanıyor.
    final uri = Uri.parse(
      'mailto:$_email'
      '?subject=${Uri.encodeComponent(_deleteSubject)}'
      '&body=${Uri.encodeComponent(body)}',
    );

    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Aşağıdaki panoya kopyalama yoluna düşüyor.
    }

    await Clipboard.setData(const ClipboardData(text: _email));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Mail uygulaması bulunamadı, adres panoya kopyalandı. '
          'Talebini bu adrese gönderebilirsin.',
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.tileColor,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadiuses.cardBorderRadius,
        ),
        title: Text(
          'Hesabın silinsin mi?',
          style: dialogContext.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Silme talebin için hazır bir e-posta açılacak. Hesabın ve üyelik '
          'bilgilerin talebin ulaştıktan sonra en geç 30 gün içinde kalıcı '
          'olarak silinir.',
          style: dialogContext.textTheme.bodyMedium?.copyWith(
            color: dialogContext.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Vazgeç',
              style: dialogContext.textTheme.bodyMedium?.copyWith(
                color: dialogContext.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Devam Et',
              style: dialogContext.textTheme.bodyMedium?.copyWith(
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
