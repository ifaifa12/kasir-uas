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

String tr(BuildContext context, String key) {
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
    
    Future.delayed(const Duration(seconds: 2), () {
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
                    'Langkah Kecil, Impian Besar ✨',
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
  String userName = 'Sobat';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('tabungan_data');
    final String? savedName = prefs.getString('userName');
    
    if (savedName != null) {
      userName = savedName;
    }

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

  Future<void> _changeUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);
    setState(() {
      userName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      TabunganScreen(
        userName: userName,
        daftarTarget: daftarTarget, 
        onUpdate: _updateState,
        onEdit: _showEditTargetDialog,
      ),
      RiwayatScreen(daftarTarget: daftarTarget, onUpdate: _updateState),
      PengaturanScreen(
        userName: userName,
        onNameChanged: _changeUserName,
      ),
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
  final String userName;
  final List<TargetTabungan> daftarTarget;
  final VoidCallback onUpdate;
  final Function(BuildContext, TargetTabungan) onEdit;
  const TabunganScreen({super.key, required this.userName, required this.daftarTarget, required this.onUpdate, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tabungan Online', style: TextStyle(fontWeight: FontWeight.w800)),
            Text('Halo $userName! Semangat menabung 🚀', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
          ],
        ),
        centerTitle: false,
        toolbarHeight: 70,
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
                                  icon: Icon(Icons.edit_rounded, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF2D3748), size: 22),
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
                      child: Text(target.nama, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF2D3748))),
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
  final String userName;
  final Function(String) onNameChanged;
  const PengaturanScreen({super.key, required this.userName, required this.onNameChanged});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  TimeOfDay? reminderTime;
  bool isReminderActive = false;
  String selectedRingtone = 'Default';

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
    final String ringtone = prefs.getString('reminderRingtone') ?? 'Default';

    if (hour != null && minute != null) {
      setState(() {
        reminderTime = TimeOfDay(hour: hour, minute: minute);
        isReminderActive = active;
        selectedRingtone = ringtone;
      });
    } else {
      setState(() {
        isReminderActive = active;
        selectedRingtone = ringtone;
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
    await prefs.setString('reminderRingtone', selectedRingtone);

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
          const Text('Profil Pengguna', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D3748) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
              ]
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.person_rounded, color: Colors.blue)
              ),
              title: const Text('Nama Profil', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(widget.userName, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              trailing: const Icon(Icons.edit_rounded, size: 20),
              onTap: () {
                _showEditNamaDialog(context);
              },
            ),
          ),
          const SizedBox(height: 32),
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
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.purpleAccent]), 
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: const Icon(Icons.palette_rounded, color: Colors.white)
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
                  const Divider(height: 1, indent: 60, endIndent: 20),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.audiotrack_rounded, color: Colors.transparent) // alignment placeholder
                    ),
                    title: const Text('Nada Dering', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(selectedRingtone, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showRingtoneDialog(context),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Data', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D3748) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
              ]
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.download_rounded, color: Colors.green)
              ),
              title: const Text('Ekspor Laporan PDF', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Unduh riwayat transaksi', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              trailing: const Icon(Icons.file_download_outlined),
              onTap: () {
                _simulasiUnduhData(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _simulasiUnduhData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            SizedBox(width: 16),
            Text('Menyiapkan file laporan...'),
          ],
        ),
        duration: Duration(seconds: 2),
      )
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Laporan berhasil diunduh ke folder Download!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    });
  }

  void _showEditNamaDialog(BuildContext context) {
    TextEditingController _namaController = TextEditingController(text: widget.userName);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Nama Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: _namaController,
          decoration: InputDecoration(
            hintText: 'Masukkan nama kamu',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3748),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (_namaController.text.isNotEmpty) {
                widget.onNameChanged(_namaController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showRingtoneDialog(BuildContext context) {
    final List<String> ringtones = ['Default', 'Ding', 'Chime', 'Morning', 'Berdering'];
    String tempSelected = selectedRingtone;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Nada Dering', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...ringtones.map((r) => RadioListTile<String>(
                  title: Text(r, style: const TextStyle(fontWeight: FontWeight.w600)),
                  value: r,
                  groupValue: tempSelected,
                  activeColor: const Color(0xFF2D3748),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setDialogState(() => tempSelected = val!),
                )),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
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
                        ),
                        onPressed: () {
                          setState(() => selectedRingtone = tempSelected);
                          _saveReminderSettings();
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
  }}