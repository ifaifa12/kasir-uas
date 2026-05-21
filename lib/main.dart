import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';

const languageNames = {
  'id': 'Bahasa Indonesia',
  'en': 'English',
  'es': 'Español',
  'fr': 'Français',
  'ja': '日本語',
  'ko': '한국어',
  'zh': '中文',
  'ar': 'العربية'
};

String tr(BuildContext context, String key) {
  final lang = Provider.of<ThemeProvider>(context).language;
  if (lang == 'id') return key;
  
  const translations = {
    'Beranda': {'en': 'Home', 'es': 'Inicio', 'fr': 'Accueil', 'ja': 'ホーム', 'ko': '홈', 'zh': '首页', 'ar': 'الرئيسية'},
    'Riwayat': {'en': 'History', 'es': 'Historial', 'fr': 'Historique', 'ja': '履歴', 'ko': '기록', 'zh': '历史', 'ar': 'سجل'},
    'Pengaturan': {'en': 'Settings', 'es': 'Ajustes', 'fr': 'Paramètres', 'ja': '設定', 'ko': '설정', 'zh': '设置', 'ar': 'إعدادات'},
    'Tabungan Online': {'en': 'Online Savings', 'es': 'Ahorros', 'fr': 'Épargne', 'ja': 'オンライン貯金', 'ko': '온라인 저축', 'zh': '在线储蓄', 'ar': 'مدخرات'},
    'Buat Target': {'en': 'New Target', 'es': 'Nuevo', 'fr': 'Nouveau', 'ja': '目標作成', 'ko': '목표 만들기', 'zh': '新建目标', 'ar': 'هدف جديد'},
    'Simpan': {'en': 'Save', 'es': 'Guardar', 'fr': 'Enregistrer', 'ja': '保存', 'ko': '저장', 'zh': '保存', 'ar': 'حفظ'},
    'Menabung': {'en': 'Save', 'es': 'Ahorrar', 'fr': 'Épargner', 'ja': '貯金する', 'ko': '저축하기', 'zh': '存钱', 'ar': 'توفير'},
    'Tarik Dana': {'en': 'Withdraw', 'es': 'Retirar', 'fr': 'Retirer', 'ja': '引き出し', 'ko': '출금', 'zh': '取款', 'ar': 'سحب'},
    'Terkumpul': {'en': 'Collected', 'es': 'Recogido', 'fr': 'Collecté', 'ja': '集まった', 'ko': '모인 금액', 'zh': '已收集', 'ar': 'مُجمع'},
    'Kekurangan': {'en': 'Remaining', 'es': 'Restante', 'fr': 'Restant', 'ja': '残り', 'ko': '남은 금액', 'zh': '剩余', 'ar': 'المتبقي'},
    'Tanggal Dibuat': {'en': 'Created Date', 'es': 'Fecha', 'fr': 'Date', 'ja': '作成日', 'ko': '생성일', 'zh': '创建日期', 'ar': 'تاريخ الإنشاء'},
    'Estimasi': {'en': 'Estimate', 'es': 'Estimado', 'fr': 'Estimation', 'ja': '予測', 'ko': '예상', 'zh': '估计', 'ar': 'تقدير'},
    'Pilih Tema': {'en': 'Select Theme', 'es': 'Tema', 'fr': 'Thème', 'ja': 'テーマを選択', 'ko': '테마 선택', 'zh': '选择主题', 'ar': 'اختر السمة'},
    'Terang': {'en': 'Light', 'es': 'Claro', 'fr': 'Clair', 'ja': 'ライト', 'ko': '밝게', 'zh': '亮色', 'ar': 'فاتح'},
    'Gelap': {'en': 'Dark', 'es': 'Oscuro', 'fr': 'Sombre', 'ja': 'ダーク', 'ko': '어둡게', 'zh': '暗色', 'ar': 'داكن'},
    'Sistem Default': {'en': 'System', 'es': 'Sistema', 'fr': 'Système', 'ja': 'システム', 'ko': '시스템', 'zh': '系统', 'ar': 'نظام'},
    'Batal': {'en': 'Cancel', 'es': 'Cancelar', 'fr': 'Annuler', 'ja': 'キャンセル', 'ko': '취소', 'zh': '取消', 'ar': 'إلغاء'},
    'Bahasa': {'en': 'Language', 'es': 'Idioma', 'fr': 'Langue', 'ja': '言語', 'ko': '언어', 'zh': '语言', 'ar': 'اللغة'},
    'Pilihan Bahasa': {'en': 'Language Options', 'es': 'Opciones', 'fr': 'Options', 'ja': '言語設定', 'ko': '언어 옵션', 'zh': '语言选项', 'ar': 'خيارات اللغة'},
    'Tema Aplikasi': {'en': 'App Theme', 'es': 'Tema de App', 'fr': 'Thème', 'ja': 'アプリテーマ', 'ko': '앱 테마', 'zh': '应用主题', 'ar': 'سمة التطبيق'},
    'Notifikasi': {'en': 'Notifications', 'es': 'Notificaciones', 'fr': 'Notifications', 'ja': '通知', 'ko': '알림', 'zh': '通知', 'ar': 'إشعارات'},
    'Pengingat Menabung': {'en': 'Savings Reminder', 'es': 'Recordatorio', 'fr': 'Rappel', 'ja': '貯金リマインダー', 'ko': '저축 알림', 'zh': '储蓄提醒', 'ar': 'تذكير'},
    'Waktu Pengingat': {'en': 'Reminder Time', 'es': 'Hora', 'fr': 'Heure', 'ja': '通知時間', 'ko': '알림 시간', 'zh': '提醒时间', 'ar': 'وقت التذكير'},
    'Belum diatur': {'en': 'Not set', 'es': 'No establecido', 'fr': 'Non défini', 'ja': '未設定', 'ko': '미설정', 'zh': '未设置', 'ar': 'غير محدد'},
    'Catat Transaksi': {'en': 'Record Transaction', 'es': 'Transacción', 'fr': 'Transaction', 'ja': '取引を記録', 'ko': '거래 기록', 'zh': '记录交易', 'ar': 'تسجيل المعاملة'},
    'Keterangan (Opsional)': {'en': 'Description (Optional)', 'es': 'Descripción', 'fr': 'Description', 'ja': '説明 (任意)', 'ko': '설명 (선택)', 'zh': '描述（可选）', 'ar': 'الوصف (اختياري)'},
    'Nominal': {'en': 'Amount', 'es': 'Monto', 'fr': 'Montant', 'ja': '金額', 'ko': '금액', 'zh': '金额', 'ar': 'المبلغ'},
    'Nama Target': {'en': 'Target Name', 'es': 'Nombre', 'fr': 'Nom', 'ja': '目標名', 'ko': '목표 이름', 'zh': '目标名称', 'ar': 'اسم الهدف'},
    'Harga Total (Rp)': {'en': 'Total Price (Rp)', 'es': 'Precio', 'fr': 'Prix', 'ja': '合計金額 (Rp)', 'ko': '총 가격 (Rp)', 'zh': '总价 (Rp)', 'ar': 'السعر الإجمالي'},
    'Nominal Rutin Menabung (Rp)': {'en': 'Routine Savings (Rp)', 'es': 'Ahorro Rutina', 'fr': 'Épargne Routine', 'ja': '定期貯金額', 'ko': '정기 저축 금액', 'zh': '日常储蓄 (Rp)', 'ar': 'التوفير الروتيني'},
    'Siklus Menabung': {'en': 'Saving Cycle', 'es': 'Ciclo', 'fr': 'Cycle', 'ja': '貯金サイクル', 'ko': '저축 주기', 'zh': '储蓄周期', 'ar': 'دورة التوفير'},
    'Unggah Foto': {'en': 'Upload Photo', 'es': 'Subir Foto', 'fr': 'Télécharger', 'ja': '写真をアップロード', 'ko': '사진 업로드', 'zh': '上传照片', 'ar': 'رفع صورة'},
    'Ubah Foto': {'en': 'Change Photo', 'es': 'Cambiar Foto', 'fr': 'Changer', 'ja': '写真を変更', 'ko': '사진 변경', 'zh': '更改照片', 'ar': 'تغيير الصورة'},
    'Target Impian Baru': {'en': 'New Dream Target', 'es': 'Nuevo Sueño', 'fr': 'Nouveau Rêve', 'ja': '新しい夢の目標', 'ko': '새로운 꿈의 목표', 'zh': '新的梦想目标', 'ar': 'هدف حلم جديد'},
    'Target Impianmu Telah Tercapai': {'en': 'Your Dream Target has been Reached', 'es': 'Alcanzado', 'fr': 'Atteint', 'ja': '夢の目標を達成しました', 'ko': '꿈의 목표를 달성했습니다', 'zh': '您的梦想目标已实现', 'ar': 'تم الوصول للهدف'},
    'Luar Biasa!': {'en': 'Awesome!', 'es': '¡Increíble!', 'fr': 'Génial !', 'ja': '素晴らしい！', 'ko': '대단해요!', 'zh': '太棒了！', 'ar': 'رائع!'},
    'Hapus Target': {'en': 'Delete Target', 'es': 'Borrar', 'fr': 'Supprimer', 'ja': '目標を削除', 'ko': '목표 삭제', 'zh': '删除目标', 'ar': 'حذف الهدف'},
    'Hapus': {'en': 'Delete', 'es': 'Borrar', 'fr': 'Supprimer', 'ja': '削除', 'ko': '삭제', 'zh': '删除', 'ar': 'حذف'},
    'Riwayat Transaksi': {'en': 'Transaction History', 'es': 'Historial', 'fr': 'Historique', 'ja': '取引履歴', 'ko': '거래 내역', 'zh': '交易记录', 'ar': 'سجل المعاملات'},
    'Belum ada target impian': {'en': 'No dream target yet', 'es': 'Sin objetivos', 'fr': 'Aucun objectif', 'ja': '夢の目標がまだありません', 'ko': '아직 꿈의 목표가 없습니다', 'zh': '尚未设置梦想目标', 'ar': 'لا يوجد هدف حلم بعد'},
    'Pilih Bahasa': {'en': 'Select Language', 'es': 'Idioma', 'fr': 'Langue', 'ja': '言語を選択', 'ko': '언어 선택', 'zh': '选择语言', 'ar': 'اختر اللغة'}
  };
  
  if (translations.containsKey(key)) {
    return (translations[key] as Map<String, String>)[lang] ?? key;
  }
  return key;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const TabunganOnlineApp(),
    ),
  );
}

class TabunganOnlineApp extends StatelessWidget {
  const TabunganOnlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Aesthetic Color Palette
    const primaryColor = Color(0xFF2D3748); // Grayish black
    const lightBg = Color(0xFFF7FAFC); 
    const darkBg = Color(0xFF1A202C);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tabungan Online',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.light),
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        scaffoldBackgroundColor: lightBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBg,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Color(0xFF2D3748), fontSize: 18, fontWeight: FontWeight.w700),
          iconTheme: IconThemeData(color: Color(0xFF2D3748)),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF7F9CF5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7F9CF5), brightness: Brightness.dark),
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: darkBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBg,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2D3748),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    
    _controller.forward();
    
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, size: 80, color: Color(0xFF2D3748)),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Tabungan Online',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masa Depan Dimulai Hari Ini',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TargetTabungan {
  String id;
  String nama;
  double nominalTarget;
  double saldoSekarang;
  Uint8List? gambarByte;
  String? tipeTarget; 
  DateTime? tanggalTarget;
  double? nominalPengisian;
  List<Transaksi> riwayat;

  TargetTabungan({
    required this.id,
    required this.nama,
    required this.nominalTarget,
    this.saldoSekarang = 0,
    this.gambarByte,
    this.tipeTarget,
    this.tanggalTarget,
    this.nominalPengisian,
    required this.riwayat,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'nominalTarget': nominalTarget,
    'saldoSekarang': saldoSekarang,
    'gambarByte': gambarByte != null ? base64Encode(gambarByte!) : null,
    'tipeTarget': tipeTarget,
    'tanggalTarget': tanggalTarget?.toIso8601String(),
    'nominalPengisian': nominalPengisian,
    'riwayat': riwayat.map((e) => e.toJson()).toList(),
  };

  factory TargetTabungan.fromJson(Map<String, dynamic> json) => TargetTabungan(
    id: json['id'],
    nama: json['nama'],
    nominalTarget: (json['nominalTarget'] as num).toDouble(),
    saldoSekarang: (json['saldoSekarang'] as num).toDouble(),
    gambarByte: json['gambarByte'] != null ? base64Decode(json['gambarByte']) : null,
    tipeTarget: json['tipeTarget'],
    tanggalTarget: json['tanggalTarget'] != null ? DateTime.parse(json['tanggalTarget']) : null,
    nominalPengisian: json['nominalPengisian'] != null ? (json['nominalPengisian'] as num).toDouble() : null,
    riwayat: (json['riwayat'] as List).map((e) => Transaksi.fromJson(e)).toList(),
  );
}

class Transaksi {
  double jumlah;
  DateTime waktu;
  String? keterangan;

  Transaksi({required this.jumlah, required this.waktu, this.keterangan});

  Map<String, dynamic> toJson() => {
    'jumlah': jumlah,
    'waktu': waktu.toIso8601String(),
    'keterangan': keterangan,
  };

  factory Transaksi.fromJson(Map<String, dynamic> json) => Transaksi(
    jumlah: (json['jumlah'] as num).toDouble(),
    waktu: DateTime.parse(json['waktu']),
    keterangan: json['keterangan'],
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<TargetTabungan> daftarTarget = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('tabungan_data');
    if (dataString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(dataString);
        setState(() {
          daftarTarget = jsonList.map((e) => TargetTabungan.fromJson(e)).toList();
        });
      } catch (e) {
        print("Error parsing data: $e");
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String dataString = jsonEncode(daftarTarget.map((e) => e.toJson()).toList());
    await prefs.setString('tabungan_data', dataString);
  }

  void _tambahTarget(TargetTabungan baru) {
    setState(() {
      daftarTarget.add(baru);
    });
    _saveData();
  }
  
  void _editTarget(String id, TargetTabungan diperbarui) {
    setState(() {
      final index = daftarTarget.indexWhere((t) => t.id == id);
      if (index != -1) {
        daftarTarget[index] = diperbarui;
      }
    });
    _saveData();
  }

  void _updateState() {
    setState(() {});
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      TabunganScreen(
        daftarTarget: daftarTarget, 
        onUpdate: _updateState,
        onEdit: _showEditTargetDialog,
      ),
      RiwayatScreen(daftarTarget: daftarTarget, onUpdate: _updateState),
      const PengaturanScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: const Color(0xFF2D3748).withOpacity(0.2),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home, color: Color(0xFF2D3748)), label: tr(context, 'Beranda')),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long, color: Color(0xFF2D3748)), label: tr(context, 'Riwayat')),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings, color: Color(0xFF2D3748)), label: tr(context, 'Pengaturan')),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showTambahTargetDialog(context),
              backgroundColor: const Color(0xFF2D3748),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              icon: const Icon(Icons.add, size: 24),
              label: Text(tr(context, 'Buat Target'), style: const TextStyle(fontWeight: FontWeight.normal)),
            )
          : null,
    );
  }

  void _showTambahTargetDialog(BuildContext context) {
    TextEditingController namaController = TextEditingController();
    TextEditingController hargaController = TextEditingController();
    TextEditingController nominalController = TextEditingController();
    Uint8List? selectedImage;
    String? selectedTipe;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : Colors.white,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Target Impian Baru', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  // Image Picker
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        var imageBytes = await image.readAsBytes();
                        setDialogState(() => selectedImage = imageBytes);
                      }
                    },
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A202C) : const Color(0xFFF7FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid),
                      ),
                        child: selectedImage == null 
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center, 
                              children: [
                                Icon(Icons.add_photo_alternate_rounded, size: 48, color: Colors.grey.withOpacity(0.7)), 
                                const SizedBox(height: 8),
                                const Text('Unggah Foto', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500))
                              ]
                            )
                          : ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.memory(selectedImage!, fit: BoxFit.contain)),
                      )
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(
                      hintText: 'Nama Target',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: hargaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Harga Total (Rp)',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nominalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nominal Rutin Menabung (Rp)',
                      hintText: 'Cth: 10000',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedTipe,
                    decoration: InputDecoration(
                      labelText: 'Siklus Menabung',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: ['Harian', 'Mingguan', 'Bulanan'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (val) => setDialogState(() => selectedTipe = val),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setDialogState(() => selectedDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedDate == null ? "Target Selesai (Opsional)" : DateFormat('dd MMM yyyy').format(selectedDate!), style: TextStyle(color: selectedDate == null ? Colors.grey.shade700 : null)),
                          Icon(Icons.calendar_month_rounded, size: 22, color: Colors.grey.shade600),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D3748),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (namaController.text.isNotEmpty && hargaController.text.isNotEmpty) {
                              _tambahTarget(TargetTabungan(
                                id: DateTime.now().toString(),
                                nama: namaController.text,
                                nominalTarget: double.parse(hargaController.text),
                                nominalPengisian: nominalController.text.isNotEmpty ? double.parse(nominalController.text) : null,
                                tipeTarget: selectedTipe ?? "Umum",
                                tanggalTarget: selectedDate,
                                gambarByte: selectedImage,
                                riwayat: [],
                              ));
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditTargetDialog(BuildContext context, TargetTabungan target) {
    TextEditingController namaController = TextEditingController(text: target.nama);
    TextEditingController hargaController = TextEditingController(text: target.nominalTarget.toInt().toString());
    TextEditingController nominalController = TextEditingController(text: target.nominalPengisian != null ? target.nominalPengisian!.toInt().toString() : '');
    
    Uint8List? selectedImage = target.gambarByte;
    String? selectedTipe = target.tipeTarget == "Umum" ? null : target.tipeTarget;
    DateTime? selectedDate = target.tanggalTarget;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : Colors.white,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit Target', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        var imageBytes = await image.readAsBytes();
                        setDialogState(() => selectedImage = imageBytes);
                      }
                    },
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A202C) : const Color(0xFFF7FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid),
                      ),
                        child: selectedImage == null 
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center, 
                              children: [
                                Icon(Icons.add_photo_alternate_rounded, size: 48, color: Colors.grey.withOpacity(0.7)), 
                                const SizedBox(height: 8),
                                const Text('Ubah Foto', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500))
                              ]
                            )
                          : ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.memory(selectedImage!, fit: BoxFit.contain)),
                      )
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(
                      labelText: 'Nama Target',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: hargaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Harga Total (Rp)',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nominalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nominal Rutin Nabung (Rp)',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedTipe,
                    decoration: InputDecoration(
                      labelText: 'Siklus Menabung',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: ['Harian', 'Mingguan', 'Bulanan'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (val) => setDialogState(() => selectedTipe = val),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setDialogState(() => selectedDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedDate == null ? "Pilih Target Selesai" : DateFormat('dd MMM yyyy').format(selectedDate!)),
                          Icon(Icons.calendar_month_rounded, size: 22, color: Colors.grey.shade600),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D3748),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (namaController.text.isNotEmpty && hargaController.text.isNotEmpty) {
                              target.nama = namaController.text;
                              target.nominalTarget = double.parse(hargaController.text);
                              target.nominalPengisian = nominalController.text.isNotEmpty ? double.parse(nominalController.text) : null;
                              target.tipeTarget = selectedTipe ?? "Umum";
                              target.tanggalTarget = selectedDate;
                              target.gambarByte = selectedImage;
                              
                              _editTarget(target.id, target);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TabunganScreen extends StatelessWidget {
  final List<TargetTabungan> daftarTarget;
  final VoidCallback onUpdate;
  final Function(BuildContext, TargetTabungan) onEdit;
  const TabunganScreen({super.key, required this.daftarTarget, required this.onUpdate, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabungan Online'),
        centerTitle: false,
      ),
      body: daftarTarget.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_circle_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(tr(context, 'Belum ada target impian'), style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100, top: 12, left: 16, right: 16),
              itemCount: daftarTarget.length,
              itemBuilder: (context, index) {
                final target = daftarTarget[index];
                double sisa = target.nominalTarget - target.saldoSekarang;
                double progress = (target.saldoSekarang / target.nominalTarget).clamp(0.0, 1.0);
                bool isTercapai = sisa <= 0;
                
                int daysRemaining = 0;
                if (target.tanggalTarget != null) {
                  daysRemaining = target.tanggalTarget!.difference(DateTime.now()).inDays;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Container(
                            height: 150,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: target.gambarByte != null ? Colors.transparent : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: target.gambarByte != null ? [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                              ] : [],
                              image: target.gambarByte != null ? DecorationImage(
                                image: MemoryImage(target.gambarByte!),
                                fit: BoxFit.cover,
                              ) : null
                            ),
                            child: target.gambarByte == null ? const Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey) : null,
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          target.nama,
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (isTercapai)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1), 
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.green.withOpacity(0.5))
                                      ),
                                      child: const Text('✨ TERCAPAI', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w800)),
                                    )
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: Color(0xFF2D3748), size: 22),
                                  onPressed: () => onEdit(context, target),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 22),
                                  onPressed: () => _showHapusDialog(context, target),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatRupiah.format(target.nominalTarget),
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6)
                                  ),
                                  child: Text(
                                    target.nominalPengisian != null 
                                      ? '${formatRupiah.format(target.nominalPengisian)} / ${target.tipeTarget ?? "Isi"}' 
                                      : 'Belum diatur',
                                    style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            CircularPercentIndicator(
                              radius: 38.0,
                              lineWidth: 6.0,
                              percent: progress,
                              animation: true,
                              center: Text("${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                              progressColor: isTercapai ? Colors.green : const Color(0xFF2D3748),
                              backgroundColor: (isTercapai ? Colors.green : const Color(0xFF2D3748)).withOpacity(0.15),
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tanggal Dibuat', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(DateFormat('dd MMM yyyy').format(DateTime.now()), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), 
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Estimasi', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(target.tanggalTarget != null ? '${daysRemaining > 0 ? daysRemaining : 0} Hari' : '-', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A202C) : const Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('Terkumpul', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text(
                                    formatRupiah.format(target.saldoSekarang),
                                    style: const TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                              Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.3)),
                              Column(
                                children: [
                                  const Text('Kekurangan', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text(
                                    sisa > 0 ? formatRupiah.format(sisa) : 'Rp0',
                                    style: const TextStyle(fontSize: 15, color: Colors.redAccent, fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!isTercapai)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D3748),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              onPressed: () => _showCatatTabunganDialog(context, target),
                              child: const Text('Menabung', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                                  SizedBox(width: 8),
                                  Text('Target Berhasil Dicapai!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              )
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showHapusDialog(BuildContext context, TargetTabungan target) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Target", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apakah kamu yakin ingin menghapus target impian ini? Data yang terhapus tidak dapat dikembalikan."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              daftarTarget.remove(target);
              onUpdate();
              Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCatatTabunganDialog(BuildContext context, TargetTabungan target) {
    TextEditingController nominalController = TextEditingController();
    TextEditingController ketController = TextEditingController();
    bool isTambah = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Catat Transaksi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A202C) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => isTambah = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isTambah ? const Color(0xFF2D3748) : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(child: Text('Menabung', style: TextStyle(fontWeight: FontWeight.bold, color: isTambah ? Colors.white : Colors.grey))),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => isTambah = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isTambah ? Colors.redAccent : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(child: Text('Tarik Dana', style: TextStyle(fontWeight: FontWeight.bold, color: !isTambah ? Colors.white : Colors.grey))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                TextField(
                  controller: nominalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nominal',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: ketController,
                  decoration: InputDecoration(
                    labelText: 'Keterangan (Opsional)',
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context), 
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTambah ? const Color(0xFF2D3748) : Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (nominalController.text.isNotEmpty) {
                            double amount = double.parse(nominalController.text);
                            if (!isTambah) amount = -amount;
                            
                            target.saldoSekarang += amount;
                            if (target.saldoSekarang < 0) target.saldoSekarang = 0;
                            
                            target.riwayat.insert(0, Transaksi(
                              jumlah: amount, 
                              waktu: DateTime.now(),
                              keterangan: ketController.text.isNotEmpty ? ketController.text : (isTambah ? 'Nabung' : 'Penarikan')
                            ));
                            
                            onUpdate();
                            Navigator.pop(context);
                            
                            if (target.saldoSekarang >= target.nominalTarget && isTambah) {
                              _showHoreDialog(context, target);
                            }
                          }
                        },
                        child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHoreDialog(BuildContext context, TargetTabungan target) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, size: 70, color: Colors.green),
              ),
              const SizedBox(height: 24),
              const Text('Hore!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Target Impianmu Telah Tercapai', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3748),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Luar Biasa!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RiwayatScreen extends StatelessWidget {
  final List<TargetTabungan> daftarTarget;
  final VoidCallback onUpdate;
  const RiwayatScreen({super.key, required this.daftarTarget, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool hasAnyRiwayat = daftarTarget.any((t) => t.riwayat.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        centerTitle: false,
      ),
      body: !hasAnyRiwayat
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('Belum ada transaksi', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              )
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daftarTarget.length,
              itemBuilder: (context, index) {
                final target = daftarTarget[index];
                if (target.riwayat.isEmpty) return const SizedBox.shrink();
                
                final riwayatTarget = List<Transaksi>.from(target.riwayat);
                riwayatTarget.sort((a, b) => b.waktu.compareTo(a.waktu));

                final formatRupiah = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, top: 8),
                      child: Text(target.nama, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF2D3748))),
                    ),
                    ...riwayatTarget.map((trx) {
                      bool isTambah = trx.jumlah > 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D3748) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isTambah ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isTambah ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, 
                                color: isTambah ? Colors.green : Colors.redAccent,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(trx.keterangan ?? (isTambah ? 'Menabung' : 'Penarikan'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(DateFormat('dd MMM yyyy • HH:mm').format(trx.waktu), style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Text(
                              '${isTambah ? '+' : ''}${formatRupiah.format(trx.jumlah)}', 
                              style: TextStyle(fontWeight: FontWeight.w900, color: isTambah ? Colors.green : Colors.redAccent, fontSize: 15)
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(height: 32, color: Colors.transparent),
                  ],
                );
              },
            ),
    );
  }
}

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  TimeOfDay? reminderTime;
  bool isReminderActive = false;

  @override
  void initState() {
    super.initState();
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final int? hour = prefs.getInt('reminderHour');
    final int? minute = prefs.getInt('reminderMinute');
    final bool active = prefs.getBool('isReminderActive') ?? false;

    if (hour != null && minute != null) {
      setState(() {
        reminderTime = TimeOfDay(hour: hour, minute: minute);
        isReminderActive = active;
      });
    }
  }

  Future<void> _saveReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (reminderTime != null) {
      await prefs.setInt('reminderHour', reminderTime!.hour);
      await prefs.setInt('reminderMinute', reminderTime!.minute);
    }
    await prefs.setBool('isReminderActive', isReminderActive);

    if (isReminderActive) {
      await NotificationService().requestPermission();
      if (reminderTime != null) {
        await NotificationService().scheduleDailyReminder(reminderTime!.hour, reminderTime!.minute);
      }
      await NotificationService().showImmediateNotification();
    } else {
      await NotificationService().cancelAllReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Tampilan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D3748) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
              ]
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF2D3748).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.palette_rounded, color: Color(0xFF2D3748))
                  ),
                  title: const Text('Tema Aplikasi', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(isDark ? 'Gelap' : 'Terang', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    _showTemaDialog(context, themeProvider);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Bahasa', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D3748) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
              ]
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.language_rounded, color: Colors.blue)
                  ),
                  title: Text(tr(context, 'Pilihan Bahasa'), style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(languageNames[themeProvider.language] ?? 'Bahasa Indonesia', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    _showBahasaDialog(context, themeProvider);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(tr(context, 'Notifikasi'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D3748) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
              ]
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.notifications_active_rounded, color: Colors.amber)
                  ),
                  title: const Text('Pengingat Menabung', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Switch(
                    value: isReminderActive,
                    onChanged: (val) {
                      setState(() => isReminderActive = val);
                      _saveReminderSettings();
                    },
                    activeColor: const Color(0xFF2D3748),
                  ),
                ),
                if (isReminderActive) ...[
                  const Divider(height: 1, indent: 60, endIndent: 20),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.access_time_rounded, color: Colors.transparent) // alignment placeholder
                    ),
                    title: const Text('Waktu Pengingat', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(reminderTime?.format(context) ?? 'Belum diatur', style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: reminderTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() => reminderTime = picked);
                        _saveReminderSettings();
                      }
                    },
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTemaDialog(BuildContext context, ThemeProvider provider) {
    ThemeMode selectedMode = provider.themeMode;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Tema', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                RadioListTile<ThemeMode>(
                  title: const Text('Sistem Default', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: ThemeMode.system,
                  groupValue: selectedMode,
                  activeColor: const Color(0xFF2D3748),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setDialogState(() => selectedMode = val!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Terang', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: ThemeMode.light,
                  groupValue: selectedMode,
                  activeColor: const Color(0xFF2D3748),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setDialogState(() => selectedMode = val!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Gelap', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: ThemeMode.dark,
                  groupValue: selectedMode,
                  activeColor: const Color(0xFF2D3748),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setDialogState(() => selectedMode = val!),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D3748),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (provider.themeMode != selectedMode) {
                            provider.setThemeMode(selectedMode);
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBahasaDialog(BuildContext context, ThemeProvider provider) {
    String selectedLang = provider.language;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr(context, 'Pilih Bahasa'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...languageNames.entries.map((entry) => RadioListTile<String>(
                  title: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w600)),
                  value: entry.key,
                  groupValue: selectedLang,
                  activeColor: const Color(0xFF2D3748),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setDialogState(() => selectedLang = val!),
                )),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: Text(tr(context, 'Batal'), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D3748),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (provider.language != selectedLang) {
                            provider.setLanguage(selectedLang);
                          }
                          Navigator.pop(ctx);
                        },
                        child: Text(tr(context, 'Simpan'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}