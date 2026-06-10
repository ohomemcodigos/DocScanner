import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';
import 'provedores/documentos_provider.dart';
import 'telas/tela_inicio.dart';
import 'telas/tela_documentos.dart';
import 'telas/tela_ferramentas.dart';
import 'telas/tela_mais.dart';

void main() {
  // 1. Esta linha é OBRIGATÓRIA quando usamos pacotes nativos (Câmera, PDF, Permissões, Biometria).
  // Ela garante que o motor do Flutter "acorde" antes da interface.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      // 2. Removido o varrer automático da inicialização.
      // Agora o app abre "vazio", respeitando a privacidade.
      // Ele só lerá o celular quando o usuário ativar na aba "Mais".
      create: (context) => DocumentosProvider(),
      child: const DocScannerApp(),
    ),
  );
=======
import 'telas/tela_inicio.dart';
import 'telas/tela_documentos.dart';
import 'telas/tela_mais.dart';

void main() {
  runApp(const DocScannerApp());
>>>>>>> 5acf77e61b9b720182375e2a4594b0e12d41ece0
}

class DocScannerApp extends StatelessWidget {
  const DocScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final isDark = context.watch<DocumentosProvider>().isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocScanner',
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF2E6AD4),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E6AD4), brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2E6AD4),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E6AD4), brightness: Brightness.dark),
=======
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocScanner',
      theme: ThemeData(
        primaryColor: const Color(0xFF2E6AD4),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E6AD4)),
        fontFamily: 'Roboto',
>>>>>>> 5acf77e61b9b720182375e2a4594b0e12d41ece0
      ),
      home: const TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _abaSelecionada = 0;

<<<<<<< HEAD
  late final List<Widget> _telas = [
    TelaInicio(onNavigateTab: (index) {
      setState(() {
        _abaSelecionada = index;
      });
    }),
    const TelaDocumentos(),
    const TelaFerramentas(),
    const TelaMais(),
=======
  final List<Widget> _telas = const [
    TelaInicio(),
    TelaDocumentos(),
    TelaMais(),
>>>>>>> 5acf77e61b9b720182375e2a4594b0e12d41ece0
  ];

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final isDark = context.watch<DocumentosProvider>().isDarkMode;
    final navColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

=======
>>>>>>> 5acf77e61b9b720182375e2a4594b0e12d41ece0
    return Scaffold(
      body: IndexedStack(
        index: _abaSelecionada,
        children: _telas,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
<<<<<<< HEAD
          color: navColor,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, -4))
=======
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
>>>>>>> 5acf77e61b9b720182375e2a4594b0e12d41ece0
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _abaSelecionada,
<<<<<<< HEAD
          onTap: (i) {
            setState(() {
              _abaSelecionada = i;
            });
          },
=======
          onTap: (i) => setState(() => _abaSelecionada = i),
>>>>>>> 5acf77e61b9b720182375e2a4594b0e12d41ece0
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF2E6AD4),
<<<<<<< HEAD
          unselectedItemColor:
              isDark ? Colors.grey[500] : const Color(0xFF8E8E93),
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Início'),
            BottomNavigationBarItem(
                icon: Icon(Icons.folder_outlined),
                activeIcon: Icon(Icons.folder),
                label: 'Arquivos'),
            BottomNavigationBarItem(
                icon: Icon(Icons.grid_view),
                activeIcon: Icon(Icons.grid_view_rounded),
                label: 'Ferramentas'),
            BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                activeIcon: Icon(Icons.more_horiz),
                label: 'Mais'),
=======
          unselectedItemColor: const Color(0xFF8E8E93),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'Documentos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              activeIcon: Icon(Icons.more_horiz),
              label: 'Mais',
            ),
>>>>>>> 5acf77e61b9b720182375e2a4594b0e12d41ece0
          ],
        ),
      ),
    );
  }
}
