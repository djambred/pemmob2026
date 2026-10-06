import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 1',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 1'),
        // Latihan 1: warna AppBar
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flutter_dash,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Halo, nama saya Jefry!',
              // Latihan 1: warna teks
              style: TextStyle(fontSize: 24, color: Colors.indigo),
            ),
            const Text('Kode Dosen: 8126'),
            const SizedBox(height: 48),
            Text(
              '$_count',
              style: const TextStyle(fontSize: 48),
            ),
          ],
        ),
      ),

      // Tombol Counter
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Tombol Kurangi
          FloatingActionButton(
            heroTag: 'kurang',
            onPressed: () {
              setState(() {
                if (_count > 0) {
                  _count--;
                }
              });
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.remove),
          ),

          // Tombol Reset
          FloatingActionButton(
            heroTag: 'reset',
            onPressed: () {
              setState(() {
                _count = 0;
              });
            },
            backgroundColor: Colors.orange,
            child: const Icon(Icons.refresh),
          ),

          // Tombol Tambah
          FloatingActionButton(
            heroTag: 'tambah',
            onPressed: () {
              setState(() {
                _count++;
              });
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
