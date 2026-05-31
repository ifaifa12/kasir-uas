import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

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
      home: const HomePage(),
    );
  }
}

// ─── Currency formatter ──────────────────────────────────────────────────────
final formatRupiah = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
String symbolMataUang(String kode) => 'Rp';

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
  String mataUang;

  // Per-target reminder fields
  bool isReminderActive;
  int? reminderHour;
  int? reminderMinute;
  List<int> reminderDays;

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
    this.mataUang = 'IDR',
    this.isReminderActive = false,
    this.reminderHour,
    this.reminderMinute,
    List<int>? reminderDays,
  }) : this.reminderDays = reminderDays ?? [1, 2, 3, 4, 5, 6, 7];

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
    'mataUang': mataUang,
    'isReminderActive': isReminderActive,
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
    'reminderDays': reminderDays,
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
    mataUang: json['mataUang'] ?? 'IDR',
    isReminderActive: json['isReminderActive'] ?? false,
    reminderHour: json['reminderHour'],
    reminderMinute: json['reminderMinute'],
    reminderDays: json['reminderDays'] != null 
        ? List<int>.from(json['reminderDays']) 
        : [1, 2, 3, 4, 5, 6, 7],
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

  // Reminder/Notif state
  TimeOfDay? reminderTime;
  bool isReminderActive = false;
  List<int> reminderDays = [1, 2, 3, 4, 5, 6, 7]; // Default to all days

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final int? hour = prefs.getInt('reminderHour');
    final int? minute = prefs.getInt('reminderMinute');
    final bool active = prefs.getBool('isReminderActive') ?? false;
    final List<String>? savedDays = prefs.getStringList('reminderDays');
    
    if (mounted) {
      setState(() {
        if (hour != null && minute != null) {
          reminderTime = TimeOfDay(hour: hour, minute: minute);
        }
        isReminderActive = active;
        if (savedDays != null) {
          reminderDays = savedDays.map((e) => int.parse(e)).toList();
        }
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
    await prefs.setStringList('reminderDays', reminderDays.map((e) => e.toString()).toList());
    
    if (isReminderActive) {
      await NotificationService().requestPermission();
      if (reminderTime != null && reminderDays.isNotEmpty) {
        await NotificationService().scheduleWeeklyReminders(reminderTime!.hour, reminderTime!.minute, reminderDays);
      }
    } else {
      await NotificationService().cancelAllReminders();
    }
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

  // ─── Dialog helpers for popup menu ────────────────────────────────────────
  void _showEditNamaDialogHome(BuildContext context) {
    final ctrl = TextEditingController(text: userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nama Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'Masukkan nama kamu',
            prefixIcon: const Icon(Icons.person_rounded),
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
              if (ctrl.text.isNotEmpty) {
                _changeUserName(ctrl.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Akses Notifikasi Diperlukan', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Text(
          'Untuk mengaktifkan pengingat menabung, aplikasi memerlukan izin notifikasi. Silakan aktifkan izin notifikasi pada Pengaturan HP Anda.',
          style: TextStyle(height: 1.4),
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
              openAppSettings();
              Navigator.pop(ctx);
            },
            child: const Text('Buka Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showNotifikasiDialogHome(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? const Color(0xFF2D3748) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifikasi', style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2D3748),
                )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pengingat Menabung', style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF2D3748),
                          )),
                          Text('Aktifkan pengingat harian', style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey,
                            fontSize: 12,
                          )),
                        ],
                      ),
                    ),
                    Switch(
                      value: isReminderActive,
                      activeColor: isDark ? const Color(0xFF7F9CF5) : const Color(0xFF2D3748),
                      onChanged: (val) async {
                        if (val) {
                          bool granted = await NotificationService().requestPermission();
                          if (!granted) {
                            if (context.mounted) {
                              _showPermissionDeniedDialog(context);
                            }
                            setDlg(() => isReminderActive = false);
                            setState(() {});
                            _saveReminderSettings();
                            return;
                          }
                        }
                        setDlg(() => isReminderActive = val);
                        setState(() {});
                        _saveReminderSettings();
                      },
                    ),
                  ],
                ),
                if (isReminderActive) ...[
                  Divider(height: 24, color: isDark ? Colors.white24 : Colors.grey.shade200),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.access_time_rounded, color: Colors.amber),
                    ),
                    title: Text('Waktu Pengingat', style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF2D3748),
                    )),
                    subtitle: Text(
                      reminderTime?.format(context) ?? 'Belum diatur',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF7F9CF5) : const Color(0xFF2D3748),
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded,
                      color: isDark ? Colors.white54 : Colors.grey),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: reminderTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setDlg(() => reminderTime = picked);
                        setState(() {});
                        _saveReminderSettings();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Hari Pengingat', style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF2D3748),
                  )),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var entry in {1: 'Sen', 2: 'Sel', 3: 'Rab', 4: 'Kam', 5: 'Jum', 6: 'Sab', 7: 'Min'}.entries)
                        ChoiceChip(
                          label: Text(entry.value),
                          selected: reminderDays.contains(entry.key),
onSelected: (selected) {
                            setDlg(() {
                              if (selected) {
                                reminderDays.add(entry.key);
                              } else {
                                reminderDays.remove(entry.key);
                              }
                            });
                            setState(() {});
                            _saveReminderSettings();
                          },
                          selectedColor: isDark ? const Color(0xFF7F9CF5) : const Color(0xFF2D3748),
                          labelStyle: TextStyle(
                            color: reminderDays.contains(entry.key)
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          backgroundColor: isDark ? Colors.white12 : Colors.grey.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        await NotificationService().showImmediateNotification();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifikasi tes dikirim!'),
                              backgroundColor: Color(0xFF2D3748),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.notifications_active_rounded, size: 18),
                      label: const Text('Tes Notif', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? const Color(0xFF7F9CF5) : const Color(0xFF2D3748),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF7F9CF5) : const Color(0xFF2D3748),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        _saveReminderSettings();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showTemaDialogHome(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    ThemeMode selectedMode = provider.themeMode;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2D3748) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tema Aplikasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                RadioListTile<ThemeMode>(
                  title: const Text('Sistem Default', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: ThemeMode.system, groupValue: selectedMode,
                  activeColor: const Color(0xFF2D3748),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setDlg(() => selectedMode = val!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Terang', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: ThemeMode.light, groupValue: selectedMode,
                  activeColor: const Color(0xFF2D3748),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setDlg(() => selectedMode = val!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Gelap', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: ThemeMode.dark, groupValue: selectedMode,
                  activeColor: const Color(0xFF2D3748),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setDlg(() => selectedMode = val!),
                ),
                const SizedBox(height: 16),
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
                          provider.setThemeMode(selectedMode);
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

  void _showEksporDialogHome(BuildContext context) {
    if (daftarTarget.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data target tabungan untuk diekspor.'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    TargetTabungan? selectedTarget; // null means All
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2D3748) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ekspor Laporan PDF', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Pilih Target yang ingin diekspor:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TargetTabungan?>(
                      value: selectedTarget,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<TargetTabungan?>(
                          value: null,
                          child: Text('Semua Target', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        ...daftarTarget.map((t) => DropdownMenuItem<TargetTabungan?>(
                          value: t,
                          child: Text(t.nama),
                        )),
                      ],
                      onChanged: (val) => setDlg(() => selectedTarget = val),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Pilih metode penyimpanan:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.blue),
                  ),
                  title: const Text('Simpan sebagai File PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Cetak atau simpan ke file lokal', style: TextStyle(fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _prosesEksporHome(context, share: false, filterTarget: selectedTarget);
                  },
                ),
                const Divider(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.share_rounded, color: Colors.green),
                  ),
                  title: const Text('Bagikan / Simpan ke Drive', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _prosesEksporHome(context, share: true, filterTarget: selectedTarget);
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _prosesEksporHome(BuildContext context, {required bool share, TargetTabungan? filterTarget}) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          SizedBox(width: 16),
          Text('Membuat dokumen PDF...'),
        ]),
        duration: Duration(seconds: 10),
      ),
    );
    try {
      final pdf = pw.Document();
      final fmt = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
      
      final targetsToExport = filterTarget != null ? [filterTarget] : daftarTarget;
      final reportTitle = filterTarget != null ? 'LAPORAN TARGET: ${filterTarget.nama.toUpperCase()}' : 'LAPORAN TABUNGAN ONLINE';
      final fileName = filterTarget != null ? 'Laporan_${filterTarget.nama}_$userName.pdf' : 'Laporan_Semua_$userName.pdf';

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => [
          pw.Text(reportTitle, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Pengguna: $userName  |  Tanggal: ${DateFormat("dd MMMM yyyy").format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
          pw.Divider(thickness: 1.5),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: ['Target', 'Nominal', 'Terkumpul', '%', 'Status'],
            data: targetsToExport.map((t) {
              final pct = (t.saldoSekarang / t.nominalTarget).clamp(0.0, 1.0);
              final sym = symbolMataUang(t.mataUang);
              return [t.nama, '$sym ${fmt.format(t.nominalTarget)}', '$sym ${fmt.format(t.saldoSekarang)}', '${(pct * 100).toInt()}%', t.saldoSekarang >= t.nominalTarget ? 'Selesai' : 'Berlangsung'];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF2D3748)),
            cellHeight: 28,
          ),
          pw.SizedBox(height: 20),
          ...targetsToExport.map((t) {
            if (t.riwayat.isEmpty) return pw.SizedBox(height: 0);
            final sym = symbolMataUang(t.mataUang);
            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Riwayat: ${t.nama}', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Waktu', 'Jenis', 'Nominal', 'Keterangan'],
                data: t.riwayat.map((trx) => [
                  DateFormat('dd/MM/yy HH:mm').format(trx.waktu),
                  trx.jumlah > 0 ? 'Nabung' : 'Tarik',
                  '$sym ${fmt.format(trx.jumlah.abs())}',
                  trx.keterangan ?? '-',
                ]).toList(),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                cellHeight: 24,
              ),
              pw.SizedBox(height: 12),
            ]);
          }).toList(),
        ],
      ));
      final bytes = await pdf.save();
      if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (share) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } else {
        await Printing.layoutPdf(onLayout: (_) async => bytes, name: fileName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
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
        onNamaProfil: () => _showEditNamaDialogHome(context),
        onNotifikasi: () => _showNotifikasiDialogHome(context),
        onTema: () => _showTemaDialogHome(context),
        onEkspor: () => _showEksporDialogHome(context),
        onNameChanged: _changeUserName,
      ),
      SelesaiScreen(
        daftarTarget: daftarTarget,
        onUpdate: _updateState,
        onEdit: _showEditTargetDialog,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: const Color(0xFF2D3748).withOpacity(0.2),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home, color: Color(0xFF2D3748)), label: tr(context, 'Berlangsung')),
          NavigationDestination(icon: const Icon(Icons.check_circle_outline_rounded), selectedIcon: const Icon(Icons.check_circle, color: Color(0xFF2D3748)), label: tr(context, 'Selesai')),
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
                      labelText: 'Harga Total',
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
                      labelText: 'Nominal Rutin Menabung',
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
                                mataUang: 'IDR',
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
                      labelText: 'Harga Total',
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
                      labelText: 'Nominal Rutin Nabung',
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
                              target.mataUang = 'IDR';
                              
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

class TabunganScreen extends StatefulWidget {
  final String userName;
  final List<TargetTabungan> daftarTarget;
  final VoidCallback onUpdate;
  final Function(BuildContext, TargetTabungan) onEdit;
  final VoidCallback onNamaProfil;
  final VoidCallback onNotifikasi;
  final VoidCallback onTema;
  final VoidCallback onEkspor;
  final Function(String) onNameChanged;

  const TabunganScreen({
    super.key,
    required this.userName,
    required this.daftarTarget,
    required this.onUpdate,
    required this.onEdit,
    required this.onNamaProfil,
    required this.onNotifikasi,
    required this.onTema,
    required this.onEkspor,
    required this.onNameChanged,
  });

  @override
  State<TabunganScreen> createState() => _TabunganScreenState();
}

class _TabunganScreenState extends State<TabunganScreen> {

  @override
  Widget build(BuildContext context) {
    final ongoingTargets = widget.daftarTarget.where((t) => t.saldoSekarang < t.nominalTarget).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tabungan Online', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Halo ${widget.userName}! Semangat menabung 🚀', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
          ],
        ),
        centerTitle: false,
        toolbarHeight: 70,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) async {
              if (value == 'nama') widget.onNamaProfil();
              else if (value == 'tema') widget.onTema();
              else if (value == 'ekspor') widget.onEkspor();
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'nama',
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.person_rounded, color: Colors.blue, size: 18)),
                  const SizedBox(width: 12),
                  const Text('Nama Profil', style: TextStyle(fontWeight: FontWeight.w600)),
                ]),
              ),

              PopupMenuItem(
                value: 'tema',
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.purpleAccent]),
                    shape: BoxShape.circle),
                    child: const Icon(Icons.palette_rounded, color: Colors.white, size: 18)),
                  const SizedBox(width: 12),
                  const Text('Tema', style: TextStyle(fontWeight: FontWeight.w600)),
                ]),
              ),
              PopupMenuItem(
                value: 'ekspor',
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.download_rounded, color: Colors.green, size: 18)),
                  const SizedBox(width: 12),
                  const Text('Ekspor', style: TextStyle(fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ongoingTargets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_circle_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(tr(context, 'Belum ada target berlangsung'), style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100, top: 12, left: 16, right: 16),
              itemCount: ongoingTargets.length,
              itemBuilder: (context, index) {
                final target = ongoingTargets[index];
                double sisa = target.nominalTarget - target.saldoSekarang;
                double progress = (target.saldoSekarang / target.nominalTarget).clamp(0.0, 1.0);
                bool isTercapai = sisa <= 0;
                
                int daysRemaining = 0;
                if (target.tanggalTarget != null) {
                  daysRemaining = target.tanggalTarget!.difference(DateTime.now()).inDays;
                  if (daysRemaining < 0) daysRemaining = 0;
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailTargetScreen(
                          target: target,
                          daftarTarget: widget.daftarTarget,
                          onUpdate: widget.onUpdate,
                          onEdit: widget.onEdit,
                          onNotifikasi: widget.onNotifikasi,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama target
                          Text(
                            target.nama,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 14),
                          // Gambar / placeholder
                          Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF1A202C)
                                  : const Color(0xFFEDF2F7),
                              borderRadius: BorderRadius.circular(16),
                              image: target.gambarByte != null
                                  ? DecorationImage(
                                      image: MemoryImage(target.gambarByte!),
                                      fit: BoxFit.cover,
                                      )
                                  : null,
                            ),
                            child: target.gambarByte == null
                                ? const Center(
                                    child: Icon(Icons.landscape_rounded, size: 56, color: Colors.grey),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          // Nominal + progress
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatRupiah.format(target.nominalTarget),
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      target.nominalPengisian != null
                                          ? '${formatRupiah.format(target.nominalPengisian)} ${target.tipeTarget ?? "Per-isi"}'
                                          : 'Belum diatur',
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              CircularPercentIndicator(
                                radius: 28.0,
                                lineWidth: 5.0,
                                percent: progress,
                                animation: true,
                                center: Text(
                                  "${(progress * 100).toInt()}%",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                                progressColor: isTercapai ? Colors.green : const Color(0xFF2D3748),
                                backgroundColor: (isTercapai ? Colors.green : const Color(0xFF2D3748)).withValues(alpha: 0.15),
                                circularStrokeCap: CircularStrokeCap.round,
                              ),
                            ],
                          ),
                          // Divider + estimasi hari
                          const Divider(height: 28),
                          Center(
                            child: Text(
                              isTercapai
                                  ? '✨ Target Tercapai!'
                                  : target.tanggalTarget != null
                                      ? '$daysRemaining Hari Lagi'
                                      : 'Tanpa batas waktu',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isTercapai ? Colors.green : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
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
              widget.daftarTarget.remove(target);
              widget.onUpdate();
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
          child: SingleChildScrollView(
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
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ketController,
                    decoration: InputDecoration(
                      labelText: 'Keterangan',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (nominalController.text.isNotEmpty) {
                              double amount = double.parse(nominalController.text);
                              if (!isTambah) amount = -amount;
                              target.saldoSekarang += amount;
                              target.riwayat.insert(0, Transaksi(jumlah: amount, waktu: DateTime.now(), keterangan: ketController.text));
                              widget.onUpdate();
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Simpan'),
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

  void _eksporLaporanPDF(BuildContext context) {
    if (widget.daftarTarget.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data target tabungan untuk diekspor.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3748) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ekspor Laporan PDF',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih metode penyimpanan laporan PDF Anda:',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.blue),
                ),
                title: const Text('Simpan sebagai File PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Cetak atau simpan langsung ke file lokal perangkat', style: TextStyle(fontSize: 12)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _prosesEkspor(context, share: false);
                },
              ),
              const Divider(height: 24),
              
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.share_rounded, color: Colors.green),
                ),
                title: const Text('Bagikan / Simpan ke Drive', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Kirim ke Google Drive, WhatsApp, Email, dll.', style: TextStyle(fontSize: 12)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _prosesEkspor(context, share: true);
                },
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _prosesEkspor(BuildContext context, {required bool share}) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            SizedBox(width: 16),
            Text('Membuat dokumen PDF...'),
          ],
        ),
        duration: Duration(seconds: 2),
      )
    );

    try {
      final pdfBytes = await _generatePdfBytes();
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (share) {
        await Printing.sharePdf(
          bytes: pdfBytes, 
          filename: 'Laporan_Tabungan_${widget.userName}.pdf',
        );
      } else {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: 'Laporan_Tabungan_${widget.userName}.pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor PDF: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<Uint8List> _generatePdfBytes() async {
    final pdf = pw.Document();
    final formatRupiah = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('LAPORAN TABUNGAN ONLINE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Nama Pengguna: ${widget.userName}', style: pw.TextStyle(fontSize: 14)),
                  pw.Text('Tanggal Ekspor: ${DateFormat("dd MMMM yyyy HH:mm").format(DateTime.now())}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            
            pw.Text('1. Ringkasan Target Tabungan', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Nama Target', 'Target Nominal', 'Saldo Sekarang', 'Progress', 'Status'],
              data: widget.daftarTarget.map((t) {
                double progress = (t.saldoSekarang / t.nominalTarget).clamp(0.0, 1.0);
                bool isTercapai = t.saldoSekarang >= t.nominalTarget;
                return [
                  t.nama,
                  formatRupiah.format(t.nominalTarget),
                  formatRupiah.format(t.saldoSekarang),
                  '${(progress * 100).toInt()}%',
                  isTercapai ? 'Selesai' : 'Berlangsung',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF2D3748)),
              cellHeight: 30,
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
              },
            ),
            pw.SizedBox(height: 24),

            pw.Text('2. Detail Riwayat Transaksi', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            ...widget.daftarTarget.map((t) {
              if (t.riwayat.isEmpty) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Target: ${t.nama}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('Belum ada transaksi.', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 12, color: PdfColors.grey)),
                    pw.SizedBox(height: 16),
                  ],
                );
              }
              
              final trxRows = t.riwayat.map((trx) {
                return [
                  DateFormat('dd MMM yyyy HH:mm').format(trx.waktu),
                  trx.jumlah > 0 ? 'Menabung (+)' : 'Penarikan (-)',
                  formatRupiah.format(trx.jumlah.abs()),
                  trx.keterangan ?? '-',
                ];
              }).toList();

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Target: ${t.nama}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.TableHelper.fromTextArray(
                    headers: ['Waktu', 'Jenis', 'Nominal', 'Keterangan'],
                    data: trxRows,
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    cellHeight: 25,
                    cellAlignment: pw.Alignment.centerLeft,
                    cellAlignments: {
                      2: pw.Alignment.centerRight,
                    },
                  ),
                  pw.SizedBox(height: 16),
                ],
              );
            }).toList(),
          ];
        },
      ),
    );

    return pdf.save();
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
}

class SelesaiScreen extends StatelessWidget {
  final List<TargetTabungan> daftarTarget;
  final VoidCallback onUpdate;
  final Function(BuildContext, TargetTabungan) onEdit;

  const SelesaiScreen({
    super.key,
    required this.daftarTarget,
    required this.onUpdate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final completedTargets = daftarTarget.where((t) => t.saldoSekarang >= t.nominalTarget).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Tercapai', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: completedTargets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('Belum ada target yang tercapai.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Terus semangat menabung! 💪', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedTargets.length,
              itemBuilder: (context, index) {
                final target = completedTargets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        image: target.gambarByte != null
                            ? DecorationImage(image: MemoryImage(target.gambarByte!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: target.gambarByte == null ? const Icon(Icons.flag_rounded, color: Colors.green) : null,
                    ),
                    title: Text(target.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Terkumpul: ${formatRupiah.format(target.saldoSekarang)}'),
                    trailing: const Icon(Icons.check_circle_rounded, color: Colors.green),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailTargetScreen(
                            target: target,
                            daftarTarget: completedTargets,
                            onUpdate: onUpdate,
                            onEdit: onEdit,
                            onNotifikasi: () {},
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class DetailTargetScreen extends StatefulWidget {
  final TargetTabungan target;
  final List<TargetTabungan> daftarTarget;
  final VoidCallback onUpdate;
  final Function(BuildContext, TargetTabungan) onEdit;
  final VoidCallback onNotifikasi;

  const DetailTargetScreen({
    super.key,
    required this.target,
    required this.daftarTarget,
    required this.onUpdate,
    required this.onEdit,
    required this.onNotifikasi,
  });

  @override
  State<DetailTargetScreen> createState() => _DetailTargetScreenState();
}

class _DetailTargetScreenState extends State<DetailTargetScreen> {
  bool isReminderActive = false;
  int globalHour = 12;
  int globalMinute = 0;

  @override
  void initState() {
    super.initState();
    _loadReminderSettings();
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Akses Notifikasi Diperlukan', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Text(
          'Untuk mengaktifkan pengingat menabung, aplikasi memerlukan izin notifikasi. Silakan aktifkan izin notifikasi pada Pengaturan HP Anda.',
          style: TextStyle(height: 1.4),
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
              openAppSettings();
              Navigator.pop(ctx);
            },
            child: const Text('Buka Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        isReminderActive = widget.target.isReminderActive;
        globalHour = prefs.getInt('reminderHour') ?? 12;
        globalMinute = prefs.getInt('reminderMinute') ?? 0;
      });
    }
  }

  Future<void> _saveReminderSettings() async {
    widget.target.isReminderActive = isReminderActive;
    
    final prefs = await SharedPreferences.getInstance();
    final int h = prefs.getInt('reminderHour') ?? 12;
    final int m = prefs.getInt('reminderMinute') ?? 0;
    final List<String>? daysStr = prefs.getStringList('reminderDays');
    final List<int> days = daysStr != null
        ? daysStr.map((e) => int.parse(e)).toList()
        : [1, 2, 3, 4, 5, 6, 7];

    widget.target.reminderHour = h;
    widget.target.reminderMinute = m;
    widget.target.reminderDays = days;

    widget.onUpdate();

    if (isReminderActive) {
      await NotificationService().requestPermission();
      if (days.isNotEmpty) {
        await NotificationService().scheduleWeeklyRemindersForTarget(
          widget.target.id,
          widget.target.nama,
          h,
          m,
          days,
        );
      }
    } else {
      await NotificationService().cancelRemindersForTarget(widget.target.id);
    }
  }

  void _showHapusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Target", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apakah kamu yakin ingin menghapus target impian ini? Data yang terhapus tidak dapat dikembalikan."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              widget.daftarTarget.remove(widget.target);
              widget.onUpdate();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    double sisa = widget.target.nominalTarget - widget.target.saldoSekarang;
    double progress = (widget.target.saldoSekarang / widget.target.nominalTarget).clamp(0.0, 1.0);
    bool isTercapai = sisa <= 0;
int daysRemaining = 0;
    if (widget.target.tanggalTarget != null) {
      daysRemaining = widget.target.tanggalTarget!.difference(DateTime.now()).inDays;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.target.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: isDark ? Colors.white : const Color(0xFF2D3748), size: 22),
            onPressed: () async {
              await widget.onEdit(context, widget.target);
              setState(() {});
              widget.onUpdate();
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 22),
            onPressed: () => _showHapusDialog(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.target.gambarByte != null ? Colors.transparent : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                boxShadow: widget.target.gambarByte != null ? [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                ] : [],
                image: widget.target.gambarByte != null ? DecorationImage(
                  image: MemoryImage(widget.target.gambarByte!),
                  fit: BoxFit.cover,
                ) : null
              ),
              child: widget.target.gambarByte == null ? const Icon(Icons.image_not_supported_outlined, size: 60, color: Colors.grey) : null,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatRupiah.format(widget.target.nominalTarget),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6)
                        ),
                        child: Text(
                          widget.target.nominalPengisian != null 
                            ? '${formatRupiah.format(widget.target.nominalPengisian)} / ${widget.target.tipeTarget ?? "Isi"}' 
                            : 'Belum diatur',
                          style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
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
            const Divider(height: 48, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tanggal Dibuat', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd MMM yyyy').format(DateTime.now()), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), 
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Estimasi', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(widget.target.tanggalTarget != null ? '${daysRemaining > 0 ? daysRemaining : 0} Hari Lagi' : '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const Divider(height: 48, thickness: 1),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D3748) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
                ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Terkumpul', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(
                        formatRupiah.format(widget.target.saldoSekarang),
                        style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w800),
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
                        style: const TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Riwayat Tabungan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            widget.target.riwayat.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Tidak Ada Riwayat Tabungan',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.target.riwayat.length,
                    itemBuilder: (context, index) {
                      final trx = widget.target.riwayat[index];
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isTambah ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isTambah ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, 
                                color: isTambah ? Colors.green : Colors.redAccent,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(trx.keterangan ?? (isTambah ? 'Menabung' : 'Penarikan'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(DateFormat('dd MMM yyyy • HH:mm').format(trx.waktu), style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Text(
                              '${isTambah ? '+' : ''}${formatRupiah.format(trx.jumlah)}', 
                              style: TextStyle(fontWeight: FontWeight.w900, color: isTambah ? Colors.green : Colors.redAccent, fontSize: 14)
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      floatingActionButton: !isTercapai
          ? FloatingActionButton(
              onPressed: () {
                _showCatatTabunganDialog(context);
              },
              backgroundColor: const Color(0xFF2D3748),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.edit_note_rounded, size: 28),
            )
          : null,
    );
  }

  void _showCatatTabunganDialog(BuildContext context) {
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
                            
                            widget.target.saldoSekarang += amount;
                            if (widget.target.saldoSekarang < 0) widget.target.saldoSekarang = 0;
                            
                            widget.target.riwayat.insert(0, Transaksi(
                              jumlah: amount, 
                              waktu: DateTime.now(),
                              keterangan: ketController.text.isNotEmpty ? ketController.text : (isTambah ? 'Nabung' : 'Penarikan')
                            ));
                            
                            setState(() {});
                            widget.onUpdate();
                            Navigator.pop(context);
                            
                            if (widget.target.saldoSekarang >= widget.target.nominalTarget && isTambah) {
                              _showHoreDialog(context);
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

  void _showHoreDialog(BuildContext context) {
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

   