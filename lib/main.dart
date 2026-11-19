import 'package:material_ui/material_ui.dart';
import 'api_client.dart';

void main() {
  runApp(const DietTrackerApp());
}

class DietTrackerApp extends StatelessWidget {
  const DietTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Diet & Workout Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Alamat server Backend Golang (Gin + GORM SQLite)
  final String baseUrl = 'http://localhost:8080/api';

  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? rekap;
  List<dynamic> daftarMakanan = [];
  List<dynamic> daftarOlahraga = [];
  Map<String, dynamic> kamusMakanan = {};

  @override
  void initState() {
    super.initState();
    muatSemuaData();
  }

  Future<void> muatSemuaData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final hasilRekap = await apiGet('$baseUrl/rekap');
      final hasilMakanan = await apiGet('$baseUrl/makanan');
      final hasilOlahraga = await apiGet('$baseUrl/olahraga');
      final hasilKamus = await apiGet('$baseUrl/kamus-makanan');

      setState(() {
        rekap = Map<String, dynamic>.from(hasilRekap as Map);
        daftarMakanan = List<dynamic>.from(hasilMakanan as List);
        daftarOlahraga = List<dynamic>.from(hasilOlahraga as List);
        kamusMakanan = Map<String, dynamic>.from(hasilKamus as Map);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage =
            'Gagal terhubung ke Server Go ($baseUrl).\nPastikan Anda sudah menjalankan:\ngo run ./backend-api';
        isLoading = false;
      });
    }
  }

  // Modal Dialog untuk Menambah Menu Baru ke Tabel SQL Kamus Makanan
  Future<void> tampilkanFormTambahKamus() async {
    final namaController = TextEditingController();
    final kaloriController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('📖 Tambah Menu ke Database Kamus'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Makanan (misal: Soto Ayam)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: kaloriController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kalori per 1 Porsi (kkal)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final nama = namaController.text.trim();
                final kal = int.tryParse(kaloriController.text) ?? 0;
                if (nama.isEmpty || kal <= 0) return;

                await apiPost('$baseUrl/kamus-makanan', {
                  'nama': nama,
                  'kalori_per_porsi': kal,
                });
                if (context.mounted) Navigator.pop(context);
                muatSemuaData();
              },
              child: const Text('Simpan ke Database'),
            ),
          ],
        );
      },
    );
  }

  // Modal Dialog untuk Menambah Makanan
  Future<void> tampilkanFormTambahMakanan() async {
    final daftarNamaKamus = kamusMakanan.keys.toList()..sort();
    String? makananTerpilih =
        daftarNamaKamus.isNotEmpty ? daftarNamaKamus.first : null;
    String waktuMakan = 'Siang';
    final porsiController = TextEditingController(text: '1');

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final estimasiKaloriPerPorsi =
                makananTerpilih != null ? (kamusMakanan[makananTerpilih] ?? 0) : 0;
            final porsi = int.tryParse(porsiController.text) ?? 1;
            final totalEstimasi = estimasiKaloriPerPorsi * porsi;

            return AlertDialog(
              title: const Text('🍽️ Catat Makanan Masuk'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih Makanan (dari Database SQL):'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: makananTerpilih,
                      isExpanded: true,
                      items: daftarNamaKamus.map((nama) {
                        final kal = kamusMakanan[nama];
                        return DropdownMenuItem(
                          value: nama,
                          child: Text('$nama ($kal kkal/porsi)'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() => makananTerpilih = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: porsiController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Porsi',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: waktuMakan,
                      decoration: const InputDecoration(
                        labelText: 'Waktu Makan',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Pagi', 'Siang', 'Malam', 'Snack']
                          .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => waktuMakan = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🔥 Estimasi Kalori: $totalEstimasi kkal (Dihitung otomatis oleh Service Go)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (makananTerpilih == null) return;
                    await apiPost('$baseUrl/makanan', {
                      'nama': makananTerpilih,
                      'porsi': int.tryParse(porsiController.text) ?? 1,
                      'waktu_makan': waktuMakan,
                    });
                    if (context.mounted) Navigator.pop(context);
                    muatSemuaData();
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Modal Dialog untuk Mencatat Olahraga (Jalan Kaki / Jogging)
  Future<void> tampilkanFormTambahOlahraga() async {
    String jenisOlahraga = 'Jalan Kaki';
    final durasiController = TextEditingController(text: '30');
    final jarakController = TextEditingController(text: '2.5');

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('🏃 Catat Olahraga'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: jenisOlahraga,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Olahraga',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Jalan Kaki',
                          child: Text('🚶 Jalan Kaki (~5 kkal/menit)'),
                        ),
                        DropdownMenuItem(
                          value: 'Jogging',
                          child: Text('🏃 Jogging (~9 kkal/menit)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => jenisOlahraga = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: durasiController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Durasi (Menit)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: jarakController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Jarak Tempuh (KM)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () async {
                    await apiPost('$baseUrl/olahraga', {
                      'jenis': jenisOlahraga,
                      'durasi_menit': int.tryParse(durasiController.text) ?? 30,
                      'jarak_km': double.tryParse(jarakController.text) ?? 0.0,
                    });
                    if (context.mounted) Navigator.pop(context);
                    muatSemuaData();
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget bangunKartuProgresOlahraga(
      String judul, Map<String, dynamic> data, Color warna) {
    final totalMenit = data['total_menit'] ?? 0;
    final targetMenit = data['target_menit'] ?? 1;
    final persen = (data['persentase'] ?? 0) as int;
    final jarak = (data['total_jarak_km'] ?? 0).toDouble();
    final kalori = data['total_kalori_terbakar'] ?? 0;
    final tercapai = data['target_tercapai'] == true;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Chip(
                  label: Text(
                    tercapai ? 'Target Tercapai ✅' : '$persen%',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor:
                      tercapai ? Colors.green.shade100 : warna.withValues(alpha: 0.15),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: (persen / 100.0).clamp(0.0, 1.0),
              minHeight: 10,
              borderRadius: BorderRadius.circular(6),
              color: warna,
            ),
            const SizedBox(height: 8),
            Text(
              '⏱️ $totalMenit / $targetMenit menit   •   📍 ${jarak.toStringAsFixed(1)} km   •   🔥 $kalori kkal',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🥗 Personal Diet & Workout Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: tampilkanFormTambahKamus,
            icon: const Icon(Icons.menu_book),
            tooltip: 'Tambah Menu ke Database Kamus',
          ),
          IconButton(
            onPressed: muatSemuaData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang Data',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 64, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: muatSemuaData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: muatSemuaData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 1. KARTU KALORI HARIAN
                      Card(
                        color: Colors.teal.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📅 Kalori Masuk Hari Ini (${rekap?['tanggal_hari_ini'] ?? ''})',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${rekap?['kalori_masuk_hari_ini'] ?? 0} / ${rekap?['batas_kalori_harian'] ?? 2000} kkal',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal),
                                  ),
                                  Text(
                                    'Sisa: ${rekap?['sisa_kuota_kalori'] ?? 0} kkal',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: ((rekap?['kalori_masuk_hari_ini'] ?? 0) /
                                        (rekap?['batas_kalori_harian'] ?? 2000))
                                    .clamp(0.0, 1.0)
                                    .toDouble(),
                                minHeight: 12,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. TOMBOL AKSI CEPAT
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: tampilkanFormTambahMakanan,
                              icon: const Icon(Icons.restaurant),
                              label: const Text('Catat Makanan'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: tampilkanFormTambahOlahraga,
                              icon: const Icon(Icons.directions_walk),
                              label: const Text('Catat Jalan/Jogging'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 3. TARGET OLAHRAGA: HARIAN, MINGGUAN, BULANAN
                      const Text(
                        '🎯 Target Jalan Kaki & Jogging',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (rekap?['olahraga_harian'] != null)
                        bangunKartuProgresOlahraga(
                          'Harian (Target Hari Ini)',
                          Map<String, dynamic>.from(rekap!['olahraga_harian']),
                          Colors.teal,
                        ),
                      if (rekap?['olahraga_mingguan'] != null)
                        bangunKartuProgresOlahraga(
                          'Mingguan (7 Hari Terakhir)',
                          Map<String, dynamic>.from(rekap!['olahraga_mingguan']),
                          Colors.blue,
                        ),
                      if (rekap?['olahraga_bulanan'] != null)
                        bangunKartuProgresOlahraga(
                          'Bulanan (Bulan Ini)',
                          Map<String, dynamic>.from(rekap!['olahraga_bulanan']),
                          Colors.purple,
                        ),

                      const SizedBox(height: 20),

                      // 4. RIWAYAT MAKANAN TERBARU (Dilengkapi Tombol Hapus SQL)
                      const Text(
                        '🍽️ Riwayat Makanan Masuk',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...daftarMakanan.reversed.map((m) => Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.fastfood),
                              ),
                              title: Text('${m['nama']} (${m['porsi']} porsi)'),
                              subtitle:
                                  Text('${m['waktu_makan']} • ${m['tanggal']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${m['kalori']} kkal',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                        fontSize: 15),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent),
                                    tooltip: 'Hapus dari Database',
                                    onPressed: () async {
                                      await apiDelete(
                                          '$baseUrl/makanan/${m['id']}');
                                      muatSemuaData();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )),

                      const SizedBox(height: 20),

                      // 5. RIWAYAT OLAHRAGA TERBARU (Dilengkapi Tombol Hapus SQL)
                      const Text(
                        '🏃 Riwayat Jalan Kaki & Jogging',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...daftarOlahraga.reversed.map((o) => Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.shade100,
                                child: Icon(
                                  o['jenis'] == 'Jogging'
                                      ? Icons.directions_run
                                      : Icons.directions_walk,
                                  color: Colors.deepOrange,
                                ),
                              ),
                              title: Text(
                                  '${o['jenis']} - ${o['durasi_menit']} menit'),
                              subtitle: Text(
                                  'Jarak: ${o['jarak_km']} km • ${o['tanggal']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '-${o['kalori_terbakar']} kkal',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange,
                                        fontSize: 15),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent),
                                    tooltip: 'Hapus dari Database',
                                    onPressed: () async {
                                      await apiDelete(
                                          '$baseUrl/olahraga/${o['id']}');
                                      muatSemuaData();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
    );
  }
}
