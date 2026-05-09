import 'package:flutter/material.dart';
import 'dart:async';

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
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF1B5E20),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
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
    Timer(const Duration(seconds: 2), () { if (mounted) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigation()));
  }
  });
  }
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color(0xFF2E7D32),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.point_of_sale_rounded, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            const Text("KASIR PRO", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            Text("Versi 1.1.0", style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ],
        )
      )
    );
  }
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
  ];

  void _onSaleComplete(Transaction trx) {
    setState(() {
      transactions.insert(0, trx);
      totalRevenue += trx.totalAfterTax;
      totalProfit += (trx.total * 0.15); // Simulated profit
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
      ),
      KasirPage(products: products, onComplete: _onSaleComplete, shopInfo: {'name': shopName, 'address': shopAddress, 'phone': shopPhone}),
      StockPage(products: products),
      LaporanGridPage(),
      ProfilePage(name: shopName, address: shopAddress, phone: shopPhone, onSave: (n, a, p) => setState(() { shopName = n; shopAddress = a; shopPhone = p; })),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Stok'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Laporan'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}

// --- 3. DASHBOARD (Sesuai Foto 2) ---
class DashboardPage extends StatelessWidget {
  final double revenue, profit;
  final String shopName, shopAddress;
  final Function(int) onNav;
  const DashboardPage({super.key, required this.revenue, required this.profit, required this.onNav, required this.shopName, required this.shopAddress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KASIR PRO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [IconButton(icon: const Icon(Icons.menu), onPressed: () {})],
      ),
      body: Column(
        children: [
          // Laporan Hari Ini Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            color: const Color(0xFF388E3C),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 24),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Laporan Hari Ini", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Row(
                        children: [
                          _stat("Total Penjualan", "Rp ${revenue.toStringAsFixed(0)}"),
                          const SizedBox(width: 20),
                          _stat("Total Profit", "Rp ${profit.toStringAsFixed(0)}"),
                        ],
                      )
                    ],
                  ),
                ),
                const Text("Versi 1.1.0", style: TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
          // Store Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.store, color: Color(0xFF2E7D32), size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(shopAddress, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit, color: Colors.grey, size: 18),
                ],
              ),
            ),
          ),
          // Grid Menu
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              crossAxisCount: 3,
                mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _menuItem(Icons.inventory_2, "Produk", Colors.orange, () => onNav(2)),
                _menuItem(Icons.history, "Riwayat", Colors.blue, () => onNav(3)),
                _menuItem(Icons.outbound, "Pengeluaran", Colors.red, () {}),
                _menuItem(Icons.description, "Laporan", Colors.purple, () => onNav(3)),
                _menuItem(Icons.print, "Cetak Resi", Colors.teal, () {}),
                _menuItem(Icons.point_of_sale, "Kasir", Colors.green, () => onNav(1)),
                _menuItem(Icons.settings, "Pengaturan", Colors.amber, () => onNav(4)),
                _menuItem(Icons.add_box, "Stok Produk", Colors.indigo, () {}),
              ],
            ),
          ),
          // Big Transaksi Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => onNav(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("TRANSAKSI", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          )
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );
}

// --- 4. KASIR & STRUK (Sesuai Foto 1) ---
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

  @override 
  Widget build(BuildContext context) {
    final filtered = widget.products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    double total = cart.fold(0, (sum, it) => sum + (it['price'] * it['qty']));

    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Produk")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: InputDecoration(
                hintText: "Cari Produk / Scan Barcode",
                prefixIcon: const Icon(Icons.qr_code_scanner),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child:  ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final p = filtered[i];
                int q = cart.firstWhere((it) => it['id'] == p.id, orElse: () => {'qty': 0})['qty'];
                return ListTile(
                  leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(p.image, width: 50, height: 50, fit: BoxFit.cover)),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Rp ${p.price.toStringAsFixed(0)} | Stok: ${p.stock}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red),onPressed: () => _updateCart(p, -1)),
                      Text("$q", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.green), onPressed: () => _updateCart(p, 1)),
                    ],
                  ),
                );
              },
            ),
          ),
          if (cart.isNotEmpty) Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Total Bayar", style: TextStyle(color: Colors.grey)), Text("Rp ${total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)))]),
                ElevatedButton(
                  onPressed: () => _showDetailTrx(total),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  child: const Text("CHECKOUT"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showDetailTrx(double total) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(color: Color(0xFFF5F5F5), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            // Header (Dark Green like Foto 1)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFF388E3C), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Detail Transaksi", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white))]),
                  const SizedBox(height: 20),
                   Row(
                    children: [
                      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.shopping_basket, color: Colors.white, size: 30)),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ID : #7", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text("${DateTime.now().toString().substring(0, 16)}", style: const TextStyle(color: Colors.white70, fontSize: 10)),
                          Text("Jumlah Pesanan : ${cart.length}", style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                      const Spacer(),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text("Total Harga :", style: TextStyle(color: Colors.white70, fontSize: 10)), Text("Rp ${total.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
                    ],
                  )
                ],
              ),
            ),
              // Info Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _info("Kasir", "Owner"),
                  _info("Metode Bayar", "Cash"),
                  _info("Bayar", "Rp ${total.toStringAsFixed(0)}"),
                  _info("Kembalian", "Rp 0"),
                ],
              ),
            ),
            // Detail Order Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Detail Order", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(children: [
                    _smallBtn("Reorder", Colors.orange),
                    const SizedBox(width: 5),
                    _smallBtn("Edit Order", Colors.green),
                  ])
                ],
              ),
            ),
            // Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: cart.length,
                itemBuilder: (context, i) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.grey),
                      const SizedBox(width: 15),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cart[i]['name'], style: const TextStyle(fontWeight: FontWeight.bold)), Text("${cart[i]['qty']} X ${cart[i]['price']}", style: const TextStyle(fontSize: 10, color: Colors.grey)), Text("SubTotal Rp ${cart[i]['qty'] * cart[i]['price']}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))])),
                      const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _actionBtn(Icons.print, "Cetak", Colors.teal),
                      const SizedBox(width: 10),
                      _actionBtn(Icons.list_alt, "Antrian", Colors.grey),
                      const SizedBox(width: 10),
                      _actionBtn(Icons.share, "Bagikan", Colors.blueGrey),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.close), label: const Text("Batalkan Pesanan"), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50))),
                  const SizedBox(height: 10),
                  TextButton.icon(onPressed: () {
                    widget.onComplete(Transaction(id: '7', method: 'Cash', total: total, tax: 0, totalAfterTax: total, date: DateTime.now(), items: List.from(cart)));
                    Navigator.pop(context);
                    Navigator.pop(context);
                    setState(() => cart = []);
                  }, icon: const Icon(Icons.delete_forever), label: const Text("Hapus Pesanan"), style: TextButton.styleFrom(foregroundColor: Colors.red)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _info(String l, String v) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontSize: 10, color: Colors.grey)), Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]);
  Widget _smallBtn(String t, Color c) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(5)), child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 10)));
  Widget _actionBtn(IconData i, String t, Color c) => Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: Icon(i, size: 16), label: Text(t, style: const TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white, padding: const EdgeInsets.all(10))));
}

// --- 5. LAPORAN GRID (Sesuai Foto 3) ---
class LaporanGridPage extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Laporan")),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 3,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        children: [
          _repItem(Icons.receipt_long, "Laporan Transaksi"),
          _repItem(Icons.shopping_bag, "Laporan Produk Terjual"),
          _repItem(Icons.inventory, "Laporan Stok Produk"),
          _repItem(Icons.category, "Laporan Kategori"),
          _repItem(Icons.outbound, "Laporan Pengeluaran"),
          _repItem(Icons.file_download, "Export Ke Excel"),
          _repItem(Icons.person, "Laporan Kasir"),
          _repItem(Icons.payments, "Laporan Metode Bayar"),
        ],
      ),
    );
  }
  Widget _repItem(IconData i, String t) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(i, color: const Color(0xFF2E7D32), size: 30),
        const SizedBox(height: 8),
        Text(t, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),   
      ],
    ),
  );
}

// --- PLACEHOLDERS ---
class StockPage extends StatelessWidget {
  final List<Product> products;
  StockPage({required this.products});
  @override 
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Stok")), body: ListView.builder(itemCount: products.length, itemBuilder: (c, i) => ListTile(title: Text(products[i].name), subtitle: Text("Stok: ${products[i].stock}"))));
}

class ProfilePage extends StatelessWidget {
  final String name, address, phone;
  final Function(String, String, String) onSave;
  ProfilePage({required this.name, required this.address, required this.phone, required this.onSave});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Profil")), body: const Center(child: Text("Halaman Profil")));
}
