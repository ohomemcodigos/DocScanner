import 'package:flutter/material.dart';

void main() {
  runApp(const DocScannerApp());
}

class DocScannerApp extends StatelessWidget {
  const DocScannerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocScanner',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: const TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({
    super.key,
  });

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _abaSelecionada = 0;

  final List<Widget> _telas = [
    const TelaInicio(),
    const Center(
        child: Text('Tela: Documentos (Histórico)',
            style: TextStyle(fontSize: 24))),
    const Center(child: Text('Tela: Mais', style: TextStyle(fontSize: 24))),
  ];

  void _aoTrocarDeAba(int indice) {
    setState(() {
      _abaSelecionada = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telas[_abaSelecionada],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaSelecionada,
        onTap: _aoTrocarDeAba,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
              icon: Icon(Icons.folder), label: 'Documentos'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Mais'),
        ],
      ),
    );
  }
}

class TelaInicio extends StatelessWidget {
  const TelaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'DocScanner',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const SizedBox(height: 50),
            const Icon(Icons.document_scanner_outlined,
                size: 100, color: Colors.blueAccent),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: () {
                print("Clicou em abrir câmera!");
              },
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text('Ecanear documento',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(280, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: () {
                print("Clicou em abrir galeria!");
              },
              icon: const Icon(Icons.image, color: Colors.blue),
              label: const Text('Importar da galeria',
                  style: TextStyle(color: Colors.blue, fontSize: 16)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue, width: 2),
                minimumSize: const Size(280, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
