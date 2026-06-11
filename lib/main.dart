import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provedores/documentos_provider.dart';
import 'provedores/usuario_provider.dart';
import 'telas/tela_inicio.dart';
import 'telas/tela_documentos.dart';
import 'telas/tela_ferramentas.dart';
import 'telas/tela_perfil.dart';

void main() {
  // Linha OBRIGATÓRIA quando se usa pacotes nativos (Câmera, PDF, Permissões, Biometria).
  // Ela garante que o motor do Flutter "acorde" antes da interface.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DocumentosProvider()),
        ChangeNotifierProvider(create: (context) => UsuarioProvider()),
      ],
      child: const DocScannerApp(),
    ),
  );
}

class DocScannerApp extends StatelessWidget {
  const DocScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
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

  late final List<Widget> _telas = [
    TelaInicio(onNavigateTab: (index) {
      setState(() {
        _abaSelecionada = index;
      });
    }),
    const TelaDocumentos(),
    const TelaFerramentas(),
    const TelaPerfil(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<DocumentosProvider>().isDarkMode;
    final navColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      body: IndexedStack(
        index: _abaSelecionada,
        children: _telas,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navColor,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, -4))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _abaSelecionada,
          onTap: (i) {
            setState(() {
              _abaSelecionada = i;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF2E6AD4),
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
                // Ícones atualizados para representar a tela de Perfil
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}