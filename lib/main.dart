import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const KasirProApp());
}

class KasirProApp extends StatelessWidget {
  const KasirProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kasir Pro',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        primaryColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          brightness: Brightness.light,
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFF334155),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          centerTitle: false,
          elevation: 0,
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color:const Color(0xFF0F172A),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// --- MODELS ---
class Product {
  final String id, name, category, image;
  double price;
  int stock;
  Product({required this.id, required this.name, required this.category, required this.image, required this.price, required this.stock});
}

class Transaction {
  final String id, method;
  final double total, tax, totalAfterTax;
  final DateTime date;
  final List<Map<String, dynamic>> items;
  Transaction({required this.id, required this.method, required this.total, required this.tax, required this.totalAfterTax, required this.date, required this.items});
}

class Expense {
  final String title;
  final double amount;
  final DateTime date;
  Expense({required this.title, required this.amount, required this.date});
}

// --- SPLASH SCREEN ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () =>  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigation())));
  }
  
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xFF0F172A),
      body: Stack(
        children: [
          Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_rounded, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text("KASIR PRO", style:  GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
            const SizedBox(height: 8),
            const Text("Solusi Bisnis Modern & Efisien", style: TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 48),
            const CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
          ],
        ),
      ),
      Positioned(
        bottom: 40,
        left: 0,
        right: 0,
        child: Column(
          children: [
            const Text("Powered by Kasir Pro", style: TextStyle(fontSize: 10, color: Colors.white54)),
          ],
        ),
      )
      ],
      ),
    );
  }

  Widget _splashMiniIcon(IconData i) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
    child: Icon(i, size: 20, color: Colors.white),
  );
}

// --- MAIN NAVIGATION ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override 
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex =0;
  String shopName = "Utusan Store";
  String shopAddress = "Desa Hariang, kec. sobang, Banten";
  String shopPhone = "0812-3456-7890";

  double totalRevenue = 0;
  double totalProfit = 0;
  List<Transaction> transactions = [];

  List<Product> products = [
    Product(id: '101', name: 'Lampu LED 15W', price: 25000, stock: 50, category: 'Elektronik', image: 'https://picsum.photos/200?random=1'),
    Product(id: '102', name: 'Kabel USB C', price: 15000, stock: 30, category: 'Aksesoris', image: 'https://picsum.photos/200?random=2'),
    Product(id: '103', name: 'Baterai AA 4pcs', price: 12000, stock: 100, category: 'Umum', image: 'https://picsum.photos/200?random=3'),
    Product(id: '104', name: 'Charger 20W', price: 85000, stock: 20, category: 'Aksesoris', image: 'https://picsum.photos/200?random=4'),
    Product(id: '105', name: 'Mouse Wireless', price: 45000, stock: 15, category: 'Elektronik', image: 'https://picsum.photos/200?random=5'),
    Product(id: '106', name: 'Keyboard Mechanical', price: 350000, stock: 10, category: 'Elektronik', image: 'https://picsum.photos/200?random=6'),
    Product(id: '107', name: 'Powerbank 10000mAh', price: 125000, stock: 25, category: 'Aksesoris', image: 'https://picsum.photos/200?random=7'),
    Product(id: '108', name: 'Headset Gaming', price: 210000, stock: 8, category: 'Elektronik', image: 'https://picsum.photos/200?random=8'),
    Product(id: '109', name: 'Flashdisk 64GB', price: 65000, stock: 40, category: 'Aksesoris', image: 'https://picsum.photos/200?random=9'),
    Product(id: '110', name: 'Webcam 1080p', price: 175000, stock: 12, category: 'Elektronik', image: 'https://picsum.photos/200?random=10'),
    Product(id: '111', name: 'Ring Light 26cm', price: 55000, stock: 18, category: 'Aksesoris', image: 'https://picsum.photos/200?random=11'),
    Product(id: '112', name: 'Stand Holder HP', price: 15000, stock: 60, category: 'Aksesoris', image: 'https://picsum.photos/200?random=12'),
    Product(id: '113', name: 'Speaker Bluetooth', price: 120000, stock: 14, category: 'Elektronik', image: 'https://picsum.photos/200?random=13'),
    Product(id: '114', name: 'Tripod 1.5m', price: 45000, stock: 22, category: 'Aksesoris', image: 'https://picsum.photos/200?random=14'),
    Product(id: '115', name: 'Microphone Clip-on', price: 25000, stock: 35, category: 'Elektronik', image: 'https://picsum.photos/200?random=15'),
  ];

  void _onSaleComplete(Transaction trx) {
    setState(() {
    final hash = DateTime.now()
    .microsecondsSinceEpoch
    .toRadixString(16).toUpperCase().substring(5);
    final newTrx = Transaction(
      id: hash,
      method: trx.method, 
      total: trx.total,
      tax: trx.tax,
      totalAfterTax: trx.totalAfterTax,
      date: trx.date,
      items: trx.items,
    );
      transactions.add(newTrx);
      totalRevenue += trx.totalAfterTax;
      totalProfit += (trx.totalAfterTax * 0.15); // Simulated profit
      for (var item in trx.items) {
        int idx = products.indexWhere((p) => p.id == item['id']);
        if (idx != -1) products[idx].stock -= (item['qty'] as int);
      }
    });
  }

  @override 
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        revenue: totalRevenue,
        profit: totalProfit,
        onNav: (i) => setState(() => _currentIndex = i),
        shopName: shopName,
        shopAddress: shopAddress,
        products: products,
        transactions: transactions,
        onShowLaporan: () => _showLaporanMenu(context),
      ),
      TransactionsHistoryPage(transactions: transactions),
      KasirPage(products: products, onComplete: _onSaleComplete, shopInfo: {'name': shopName, 'address': shopAddress, 'phone': shopPhone}),
      StockPage(products: products, onAdd: (p) => setState(() => products.add((p)))),
      ProfilePage(name: shopName, address: shopAddress, phone: shopPhone, onSave: (n, a, p) => setState(() { shopName = n; shopAddress = a; shopPhone = p; })),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF64748B),
        unselectedItemColor: Colors.grey[500],
        backgroundColor: Colors.white,
        elevation: 10,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        iconSize: 22,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Stok'),
        BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }

  void _showLaporanMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pilih Laporan", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 24),
            _laporanItem(context, Icons.insights_rounded, "Laporan Penjualan", Colors.green, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => SalesSummaryPage(transactions: transactions)));
            }),
            _laporanItem(context, Icons.inventory_2_rounded, "Laporan Stok", Colors.orange, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => StockReportView(products: products)));
            }),
            _laporanItem(context, Icons.account_balance_wallet_rounded, "Laporan Pengeluaran", Colors.red, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => ExpenseReportPage(expenses: []))); // Pass actual expenses if tracked
            }),
          ],
        ),
      ),
    );
  }

  Widget _laporanItem(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) => ListTile(
    leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );
}

// --- NEW TRANSACTIONS HISTORY PAGE ---
class TransactionsHistoryPage extends StatelessWidget {
  final List<Transaction> transactions;
  const TransactionsHistoryPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RIWAYAT TRANSAKSI")),
      body: transactions.isEmpty 
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.history_rounded, size: 64, color: Colors.grey[300]), const SizedBox(height: 16), const Text("Belum ada riwayat", style: TextStyle(color: Colors.grey))]))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, i) {
              final t = transactions[transactions.length - 1 - i]; // Show newest first
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[100]!)),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF64748B))),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("INV-${t.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text("${t.method} • ${t.items.length} item", style: const TextStyle(fontSize: 11, color: Colors.grey))])),
                    Text("Rp ${t.totalAfterTax.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                  ],
                ),
              );
            },
          ),
    );
  }
}

// --- 3. DASHBOARD (Sesuai Foto 2) ---
class DashboardPage extends StatelessWidget {
  final double revenue, profit;
  final String shopName, shopAddress;
  final Function(int) onNav;
  final List<Product> products;
  final List<Transaction> transactions;
  final VoidCallback onShowLaporan;
  const DashboardPage({super.key, required this.revenue, required this.profit, required this.onNav, required this.shopName, required this.shopAddress, required this.products, required this.transactions, required this.onShowLaporan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BERANDA"),
        actions: [IconButton(icon: const Icon(Icons.notifications_none, size: 20), onPressed: () => _showNotifications(context))],
      ),
      body: Column(
        children: [
          // Laporan Hari Ini Bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0F1724), Color(0xFF334155)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: const Color(0xFF64748B).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Pendapatan", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text("Rp ${revenue.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statSmall("Profit", "Rp ${profit.toStringAsFixed(0)}", Colors.greenAccent),
                    _statSmall("Transaksi", "${transactions.length}", Colors.blueAccent),
                    _statSmall("Produk", "${products.length}", Colors.orangeAccent),
                  ],
                )
              ],
            ),
          ),
          // Grid Menu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _menuItem(Icons.bar_chart_rounded, "Laporan", const Color(0xFF0F172A), onShowLaporan),
                _menuItem(Icons.account_balance_wallet_rounded, "Biaya", Colors.redAccent, () => _showExpenseDialog(context)),
                _menuItem(Icons.history_rounded, "Riwayat", Colors.blueAccent, () => onNav(3)), 
                _menuItem(Icons.receipt_long_rounded, "Cetak Struk", Colors.purpleAccent, () => _showPrintList(context)),
                _menuItem(Icons.people_alt_rounded, "Pelanggan", Colors.orangeAccent, () {}),
              ],
            ),
          ),

          //Recent Transaction
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Transaksi Terakhir", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 8),
                if (transactions.isEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_outlined, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          const Text("Belum ada transaksi hari ini", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                else
                  ...transactions.take(5).map((t) => _trxTile(t)),
              ],
            ),
          )
        ],
      ),
    );
  }

    void _showExpenseDialog(BuildContext context) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("Tambah Pengeluaran"),
      content: const Column(mainAxisSize: MainAxisSize.min, children: [TextField(decoration: InputDecoration(hintText: "Keperluan")), SizedBox(height: 10), TextField(decoration: InputDecoration(hintText: "Jumlah"), keyboardType: TextInputType.number)]),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("Batal")), ElevatedButton(onPressed: () => Navigator.pop(c), child: const Text("Simpan"))],
    ));
  }


  Widget _statSmall(String label, String v, Color c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      Text(v, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 12)),
    ],
  );

  Widget _menuItem(IconData icon, String label, Color color, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
        ],
      ),
    ),
  );

   Widget _trxTile(Transaction t) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.receipt_rounded, size: 20, color: Color(0xFF0F172A)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text("INV-${t.id}", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))), 
              Text("${t.items.length} item • ${t.method}", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ]
          )
        ),
        Text("Rp ${t.totalAfterTax.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.green)),
      ],
    ),
  );
   void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pemberitahuan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _notifItem("Stok Rendah", "Produk 'Headset Gaming' sisa 8 pcs", Colors.orange),
            _notifItem("Target Penjualan", "Kamu mencapai 80% target hari ini!", Colors.green),
            _notifItem("Update Sistem", "Kasir Pro v1.2.0 telah tersedia", Colors.blue),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup"))],
      ),
    );
  }

  Widget _notifItem(String t, String s, Color c) => ListTile(
    leading: Icon(Icons.circle, size: 10, color: c),
    title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    subtitle: Text(s, style: const TextStyle(fontSize: 11)),
    contentPadding: EdgeInsets.zero,
  );

  void _showPrintList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pilih Struk untuk Dicetak", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: transactions.isEmpty 
                ? const Center(child: Text("Belum ada transaksi hari ini"))
                : ListView.builder(
                    itemCount: transactions.length,
                     itemBuilder: (context, i) {
                      final trx = transactions[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.print_rounded, size: 18, color: Color(0xFF64748B)),
                          title: Text("INV-${trx.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          subtitle: Text("Rp ${trx.totalAfterTax.toStringAsFixed(0)} • ${trx.method}", style: const TextStyle(fontSize: 10)),
                          trailing: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menghubungkan ke Printer...")));
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12), minimumSize: const Size(0, 30)),
                            child: const Text("Cetak", style: TextStyle(fontSize: 10)),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}


// --- 4. KASIR PAGE ---
class KasirPage extends StatefulWidget {
  final List<Product> products;
  final Function (Transaction) onComplete;
  final Map<String, String> shopInfo;
  const KasirPage({super.key, required this.products, required this.onComplete, required this.shopInfo});
  @override 
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  List<Map<String, dynamic>> cart = [];
  String query ="";
  String selectedMethod = "Tunai";

  void _updateCart(Product p, int delta) {
    setState(() {
      int idx = cart.indexWhere((it) => it['id'] == p.id);
      if (idx != -1) {
        cart[idx]['qty'] += delta;
        if (cart[idx]['qty'] <= 0) cart.removeAt(idx);
      } else if (delta > 0) {
        cart.add({'id': p.id, 'name': p.name, 'price': p.price, 'qty': 1});
      }
    });
  }
  void _showScanner() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            children: [
              MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final code = barcode.rawValue;
                    if (code != null) {
                      final pIdx = widget.products.indexWhere((p) => p.id == code);
                      if (pIdx != -1) {
                        _updateCart(widget.products[pIdx], 1);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Berhasil scan: ${widget.products[pIdx].name}"), duration: const Duration(seconds: 1)));
                        return;
                      }
                    }
                  }
                },
              ),
              Center(child: Container(width: 200, height: 200, decoration: BoxDecoration(border: Border.all(color: Colors.white54, width: 2), borderRadius: BorderRadius.circular(12)))),
              Positioned(top: 10, right: 10, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, {bool isAdd = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isAdd ? const Color(0xFF0F172A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: isAdd ? Colors.white : const Color(0xFF0F172A)),
      ),
    );
  }

  @override 
  Widget build(BuildContext context) {
    final filtered = widget.products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    double total = cart.fold(0, (sum, it) => sum + (it['price'] * it['qty']));

   return Scaffold(
      appBar: AppBar(
        title: const Text("KASIR"), 
        actions: [if(cart.isNotEmpty) IconButton(icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent), onPressed: () => setState(() => cart = []))]
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => query = v),
                    decoration: InputDecoration(
                      hintText: "Cari Produk",
                      prefixIcon: const Icon(Icons.search_rounded, size: 22, color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0F172A))),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _showScanner,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Product List
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final p = filtered[i];
                      int q = cart.firstWhere((it) => it['id'] == p.id, orElse: () => {'qty': 0})['qty'];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[100]!)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 55, height: 55,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
                            child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(p.image, fit: BoxFit.cover)),
                          ),
                          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                    child: Text(p.category, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text("Stok: ${p.stock}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text("Rp ${p.price.toStringAsFixed(0)}", style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w900)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (q > 0) ...[
                                _qtyBtn(Icons.remove_rounded, () => _updateCart(p, -1)),
                                Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text("$q", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900))),
                              ],
                              _qtyBtn(Icons.add_rounded, () => _updateCart(p, 1), isAdd: true),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Rincian Belanja Sidebar (Desktop-like) or just a small section
                if (cart.isNotEmpty && MediaQuery.of(context).size.width > 600) ...[
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(padding: EdgeInsets.all(16), child: Text("Rincian Belanja", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                        Expanded(
                          child: ListView.builder(
                            itemCount: cart.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (c, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text("${cart[i]['qty']}x ${cart[i]['name']}", style: const TextStyle(fontSize: 12))),
                                  Text("Rp ${cart[i]['qty'] * cart[i]['price']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
          if (cart.isNotEmpty) Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rincian for mobile (inside the bottom panel)
                  if (MediaQuery.of(context).size.width <= 600) ...[
                    const Text("Rincian Belanja", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 100),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: cart.length > 3 ? 3 : cart.length,
                        itemBuilder: (c, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${cart[i]['qty']}x ${cart[i]['name']}", style: const TextStyle(fontSize: 11)),
                              Text("Rp ${cart[i]['qty'] * cart[i]['price']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (cart.length > 3) const Text("...", style: TextStyle(color: Colors.grey)),
                    const Divider(),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Total Bayar", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text("Rp ${total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _showCheckout(total),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A), 
                          foregroundColor: Colors.white, 
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text("PROSES BAYAR", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showCheckout(double total) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
         builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          child: Column(
           children: [
              Container(height: 4, width: 40, margin: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Pilih Metode Pembayaran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))]),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)]),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text("Total Bayar", style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 8),
                          Text("Rp ${total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text("Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _payMethodItem("Tunai", Icons.payments_rounded, selectedMethod == "Tunai", () => setModalState(() => selectedMethod = "Tunai")),
                        _payMethodItem("ShopeePay", Icons.account_balance_wallet_rounded, selectedMethod == "ShopeePay", () => setModalState(() => selectedMethod = "ShopeePay")),
                        _payMethodItem("Dana", Icons.wallet_rounded, selectedMethod == "Dana", () => setModalState(() => selectedMethod = "Dana")),
                        _payMethodItem("QRIS", Icons.qr_code_2_rounded, selectedMethod == "QRIS", () => setModalState(() => selectedMethod = "QRIS")),
                        _payMethodItem("Transfer", Icons.account_balance_rounded, selectedMethod == "Transfer", () => setModalState(() => selectedMethod = "Transfer")),
                      ],
                    ),
                  ],
                ),
              ),
             Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: () {
                    final trx = Transaction(id: '${DateTime.now().millisecondsSinceEpoch}', method: selectedMethod, total: total, tax: 0, totalAfterTax: total, date: DateTime.now(), items: List.from(cart));
                    widget.onComplete(trx);
                    Navigator.pop(context);
                    _showReceipt(trx);
                    setState(() => cart = []);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A), 
                    foregroundColor: Colors.white, 
                    minimumSize: const Size(double.infinity, 60), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                  ),
                  child: const Text("SELESAIKAN TRANSAKSI", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget _payMethodItem(String l, IconData i, bool sel, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      width: (MediaQuery.of(context).size.width - 72) / 3,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: sel ? const Color(0xFF0F172A) : Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: sel ? const Color(0xFF0F172A) : Colors.grey[200]!),
        boxShadow: sel ? [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))] : [],
      ),
      child: Column(
        children: [
          Icon(i, color: sel ? Colors.white : const Color(0xFF64748B), size: 20),
          const SizedBox(height: 6),
          Text(l, style: TextStyle(color: sel ? Colors.white : const Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );


  void _showReceipt(Transaction trx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  child: const Column(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 48),
                      SizedBox(height: 12),
                      Text("Transaksi Berhasil", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(widget.shopInfo['name']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      Text(widget.shopInfo['address']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const Divider(height: 32),
                      ...trx.items.map((it) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${it['qty']}x ${it['name']}", style: const TextStyle(fontSize: 12)),
                            Text("Rp ${it['qty'] * it['price']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("TOTAL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          Text("Rp ${trx.totalAfterTax.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Metode Pembayaran", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(trx.method, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text("TUTUP", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- STOCK PAGE ---
class StockPage extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onAdd;
  const StockPage({super.key, required this.products, required this.onAdd});
  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  void _showAddProduct() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final catCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Produk Baru"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nama Produk")),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: "Kategori")),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
              TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: "Stok"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(onPressed: () {
            final p = Product(
              id: '${DateTime.now().millisecondsSinceEpoch}',
              name: nameCtrl.text,
              category: catCtrl.text,
              price: double.tryParse(priceCtrl.text) ?? 0,
              stock: int.tryParse(stockCtrl.text) ?? 0,
              image: 'https://picsum.photos/200?random=${DateTime.now().second}',
            );
            widget.onAdd(p);
            Navigator.pop(context);
          }, child: const Text("Tambah")),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("STOK PRODUK"), actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: _showAddProduct)]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.products.length,
        itemBuilder: (context, i) {
          final p = widget.products[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[100]!)),
            child: Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(p.image, width: 45, height: 45, fit: BoxFit.cover)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), Text(p.category, style: const TextStyle(fontSize: 11, color: Colors.grey))])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text("${p.stock}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: p.stock < 10 ? Colors.redAccent : const Color(0xFF0F172A))), const Text("Stok", style: TextStyle(fontSize: 10, color: Colors.grey))]),
              ],
            ),
          );
        },
      ),
    );
  } 
}

// --- PROFILE / SETTINGS PAGE ---
class ProfilePage extends StatelessWidget {
  final String name, address, phone;
  final Function(String, String, String) onSave;
  const ProfilePage({super.key, required this.name, required this.address, required this.phone, required this.onSave});

  void _editInfo(BuildContext context, String title, String current, Function(String) onUpdate) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ubah $title"),
        content: TextField(controller: controller, decoration: InputDecoration(hintText: "Masukkan $title baru")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(onPressed: () { onUpdate(controller.text); Navigator.pop(context); }, child: const Text("Simpan")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PENGATURAN")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey[200]!)),
                  child: const Icon(Icons.storefront_rounded, size: 40, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text("Informasi Toko", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          _settingTile(context, Icons.store_rounded, "Nama Toko", name, (v) => onSave(v, address, phone)),
          _settingTile(context, Icons.location_on_rounded, "Alamat", address, (v) => onSave(name, v, phone)),
          _settingTile(context, Icons.phone_rounded, "Nomor Telepon", phone, (v) => onSave(name, address, v)),
          const SizedBox(height: 32),
          const Text("Aplikasi", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          _settingTile(context, Icons.print_rounded, "Printer & Struk", "Belum terhubung", (_) {}),
          _settingTile(context, Icons.cloud_done_rounded, "Cadangkan Data", "Cloud Sync Aktif", (_) {}),
          const SizedBox(height: 48),
          const Center(child: Text("Kasir Pro v1.2.0 • Build Local", style: TextStyle(color: Colors.grey, fontSize: 10))),
        ],
      ),
    );
  }

  Widget _settingTile(BuildContext context, IconData i, String t, String v, Function(String) onEdit) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[100]!)),
    child: Row(
      children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)), child: Icon(i, size: 20, color: const Color(0xFF64748B))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontSize: 11, color: Colors.grey)), Text(v, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))])),
        IconButton(icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.grey), onPressed: () => _editInfo(context, t, v, onEdit)),
      ],
    ),
  );
}

class SalesSummaryPage extends StatelessWidget {
  final List<Transaction> transactions;
  const SalesSummaryPage({super.key, required this.transactions});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RINGKASAN PENJUALAN")),
      body: transactions.isEmpty 
        ? const Center(child: Text("Belum ada transaksi"))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, i) {
              final t = transactions[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text("Transaksi #${t.id.substring(t.id.length-5)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${t.items.length} Item • ${t.method}"),
                  trailing: Text("Rp ${t.totalAfterTax.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green)),
                ),
              );
            },
          ),
    );
  }
}

class StockReportView extends StatelessWidget {
  final List<Product> products;
  const StockReportView({super.key, required this.products});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LAPORAN STOK")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, i) {
          final p = products[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(p.category),
              trailing: Text("${p.stock}", style: TextStyle(fontWeight: FontWeight.w900, color: p.stock < 10 ? Colors.red : Colors.black)),
            ),
          );
        },
      ),
    );
  }
}

class ExpenseReportPage extends StatelessWidget {
  final List<Expense> expenses;
  const ExpenseReportPage({super.key, required this.expenses});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LAPORAN PENGELUARAN")),
      body: expenses.isEmpty 
        ? const Center(child: Text("Belum ada pengeluaran"))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            itemBuilder: (context, i) {
              final e = expenses[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${e.date.day}/${e.date.month}/${e.date.year}"),
                  trailing: Text("Rp ${e.amount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.red)),
                ),
              );
            },
          ),
    );
  }
}
