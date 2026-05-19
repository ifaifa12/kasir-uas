import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';

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
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tabungan Online',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF4F9F4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F9F4),
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    
    _controller.forward();
    
    Future.delayed(const Duration(seconds: 3), () {
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
      backgroundColor: const Color(0xFF212121),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet, size: 100, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'Tabungan Online',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masa Depan Cerah Dimulai dari Sekarang',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
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
  List<Transaksi> riwayat;

  TargetTabungan({
    required this.id,
    required this.nama,
    required this.nominalTarget,
    this.saldoSekarang = 0,
    this.gambarByte,
    this.tipeTarget,
    this.tanggalTarget,
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
    riwayat: (json['riwayat'] as List).map((e) => Transaksi.fromJson(e)).toList(),
  );
}

class Transaksi {
  double jumlah;
  DateTime waktu;
  Transaksi({required this.jumlah, required this.waktu});

  Map<String, dynamic> toJson() => {
    'jumlah': jumlah,
    'waktu': waktu.toIso8601String(),
  };

  factory Transaksi.fromJson(Map<String, dynamic> json) => Transaksi(
    jumlah: (json['jumlah'] as num).toDouble(),
    waktu: DateTime.parse(json['waktu']),
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

  void _updateState() {
    setState(() {});
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.teal)));
    }

    final screens = [
      TabunganScreen(daftarTarget: daftarTarget, onUpdate: _updateState),
      RiwayatScreen(daftarTarget: daftarTarget, onUpdate: _updateState),
      const PengaturanScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Tabungan'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showTambahTargetDialog(context),
              backgroundColor: const Color(0xFF212121), // Hitam / Abu-abu gelap
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text(
                'Buat Target',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  void _showTambahTargetDialog(BuildContext context) {
    TextEditingController namaController = TextEditingController();
    TextEditingController hargaController = TextEditingController();
    Uint8List? selectedImage;
    String? selectedTipe;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.track_changes, color: Colors.red, size: 24),
                      const SizedBox(width: 8),
                      const Text('Target Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: namaController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.edit, size: 20),
                      hintText: 'Mau beli apa?',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: hargaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.money, size: 20),
                      hintText: 'Harga (Rp)',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('Siklus Nabung', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  DropdownButton<String>(
                    value: selectedTipe,
                    isExpanded: true,
                    hint: const Text("Pilih Siklus"),
                    items: ['Harian', 'Mingguan', 'Bulanan', 'Tahunan'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (val) => setDialogState(() => selectedTipe = val),
                  ),
                  const SizedBox(height: 10),
                  const Text('Tanggal Target', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(selectedDate == null ? "Pilih Tanggal" : DateFormat('dd MMM yyyy').format(selectedDate!)),
                    trailing: const Icon(Icons.calendar_month, color: Colors.green, size: 20),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setDialogState(() => selectedDate = picked);
                    },
                  ),
                  const SizedBox(height: 15),
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
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: selectedImage == null
                          ? const Center(child: Text('Tambah Foto', style: TextStyle(color: Colors.grey, fontSize: 12)))
                          : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(selectedImage!, fit: BoxFit.contain)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                      ElevatedButton(
                        onPressed: () {
                          if (namaController.text.isNotEmpty && hargaController.text.isNotEmpty) {
                            _tambahTarget(TargetTabungan(
                              id: DateTime.now().toString(),
                              nama: namaController.text,
                              nominalTarget: double.parse(hargaController.text),
                              tipeTarget: selectedTipe ?? "Umum",
                              tanggalTarget: selectedDate,
                              gambarByte: selectedImage,
                              riwayat: [],
                            ));
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Simpan'),
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
  const TabunganScreen({super.key, required this.daftarTarget, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabungan Online', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: false,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF212121),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.white30, height: 1.0),
        ),
      ),
      body: daftarTarget.isEmpty
          ? const Center(child: Text('Belum ada target. klik + untuk menambah'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: daftarTarget.length,
              itemBuilder: (context, index) {
                final target = daftarTarget[index];
                double sisa = target.nominalTarget - target.saldoSekarang;
                double progress = (target.saldoSekarang / target.nominalTarget).clamp(0.0, 1.0);
                final formatRupiah = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- KARTU TARGET SESUAI GAMBAR ---
                    Container(
                      margin: const EdgeInsets.all(15),
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF757575), Color(0xFF212121), Color(0xFF000000)], // Gradasi abu-abu ke hitam
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Hapus Target"),
                                      content: const Text("Apakah kamu yakin ingin menghapus target ini beserta riwayatnya?"),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () {
                                            daftarTarget.remove(target);
                                            onUpdate();
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text("Hapus", style: TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Icon(Icons.delete_outline, color: Colors.white70, size: 22),
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Center(
                            child: Text(
                              'Target Barang Impian',
                              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (target.gambarByte != null) ...[
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  target.gambarByte!,
                                  height: 120, // Diperkecil lagi dan menggunakan fit contain
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                          Center(
                            child: Text(
                              target.nama.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '${formatRupiah.format(target.saldoSekarang)} / ${formatRupiah.format(target.nominalTarget)}',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(height: 15),
                          if (sisa <= 0)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.withOpacity(0.5)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.celebration, color: Colors.white70),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Yey! Selamat tabunganmu sudah penuh!',
                                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Text(
                              'Kurang ${formatRupiah.format(sisa)} untuk mencapai ${formatRupiah.format(target.nominalTarget)}',
                              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          const SizedBox(height: 15),
                          if (sisa > 0)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showNabungDialog(context, target),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text("Menabung"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF424242),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  elevation: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  void _showNabungDialog(BuildContext context, TargetTabungan target) {
    TextEditingController nominalController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nabung: ${target.nama}'),
        content: TextField(
          controller: nominalController, 
          decoration: const InputDecoration(hintText: 'Jumlah (Rp)'), 
          keyboardType: TextInputType.number
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (nominalController.text.isNotEmpty) {
                target.saldoSekarang += double.parse(nominalController.text);
                target.riwayat.insert(0, Transaksi(jumlah: double.parse(nominalController.text), waktu: DateTime.now()));
                onUpdate();
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
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
        title: Text('Semua Riwayat', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)), 
        centerTitle: false,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF212121),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.white30, height: 1.0),
        ),
      ),
      body: !hasAnyRiwayat
          ? const Center(child: Text('Belum ada riwayat', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: daftarTarget.length,
              itemBuilder: (context, index) {
                final target = daftarTarget[index];
                if (target.riwayat.isEmpty) return const SizedBox.shrink();
                
                final riwayatTarget = List<Transaksi>.from(target.riwayat);
                riwayatTarget.sort((a, b) => b.waktu.compareTo(a.waktu));

                final formatRupiah = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nabung Target:', style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(target.nama, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black)),
                          const SizedBox(height: 8),
                          Container(height: 1.5, color: isDark ? Colors.white30 : Colors.black),
                        ],
                      ),
                    ),
                    ...riwayatTarget.map((trx) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shadowColor: Colors.black12,
                        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_downward, color: Colors.green),
                          ),
                          title: Text(target.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(DateFormat('dd MMM yyyy • HH:mm').format(trx.waktu), style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600, fontSize: 12)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('+ ${formatRupiah.format(trx.jumlah)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Hapus Transaksi"),
                                      content: const Text("Yakin ingin menghapus transaksi ini? Saldo target akan ikut berkurang."),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () {
                                            target.saldoSekarang -= trx.jumlah;
                                            if (target.saldoSekarang < 0) target.saldoSekarang = 0;
                                            target.riwayat.remove(trx);
                                            onUpdate();
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text("Hapus", style: TextStyle(color: Colors.white)),
                                        )
                                      ]
                                    )
                                  );
                                },
                                child: const Text("Hapus", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 15),
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

    if (isReminderActive && reminderTime != null) {
      await NotificationService().scheduleDailyReminder(reminderTime!.hour, reminderTime!.minute);
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
        title: Text('Pengaturan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF212121),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Tampilan'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            child: ListTile(
              leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: Colors.teal),
              title: const Text('Mode Gelap'),
              trailing: Switch(
                value: isDark,
                onChanged: (val) => themeProvider.toggleTheme(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Notifikasi'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active, color: Colors.orange),
                  title: const Text('Pengingat Menabung'),
                  trailing: Switch(
                    value: isReminderActive,
                    onChanged: (val) {
                      setState(() => isReminderActive = val);
                      _saveReminderSettings();
                    },
                  ),
                ),
                if (isReminderActive)
                  ListTile(
                    leading: const Icon(Icons.access_time, color: Colors.blue),
                    title: const Text('Waktu Pengingat'),
                    subtitle: Text(reminderTime?.format(context) ?? 'Belum diatur'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                const Icon(Icons.account_balance_wallet, size: 50, color: Colors.grey),
                const SizedBox(height: 8),
                Text('Tabungan Online v1.0.0', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
      ),
    );
  }
}