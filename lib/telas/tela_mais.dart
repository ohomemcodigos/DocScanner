import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/documentos_provider.dart';

class TelaMais extends StatelessWidget {
  const TelaMais({super.key});

  void _mostrarSobreApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sobre o DocScanner',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'O DocScanner é uma solução desenvolvida para simplificar a digitalização, gestão e edição de documentos.\n\n'
          'Através do uso de algoritmos nativos e processamento em dispositivo, garantimos a privacidade e velocidade na conversão dos seus papéis em ficheiros PDF de alta qualidade.\n\n'
          'Versão: 1.0.0-MVP',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
        ],
      ),
    );
  }

  // Confirmação antes de disparar a Revogação Ativa
  void _confirmarRevogacao(BuildContext context, DocumentosProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revogar Acesso',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Ao desativar esta opção, todos os documentos que foram encontrados automaticamente pelo DocScanner serão removidos da sua lista.\n\n'
          'Fique tranquilo: os seus arquivos originais no armazenamento do celular NÃO serão apagados. Deseja continuar?',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.alternarPermissaoArquivos(false); // Dispara a limpeza no SQLite
            },
            child: const Text('Desativar',
                style: TextStyle(color: Color(0xFFFF4B4B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentosProvider>();
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A3A6B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        titleSpacing: 20,
        title: Text('Mais',
            style: TextStyle(
                color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPerfilCard(),
            const SizedBox(height: 20),

            // Configurações e Acessos
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 10),
                    child: Text('Configurações do Sistema',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8E8E93),
                            letterSpacing: 0.5))),
                Container(
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      // Toggle de Acesso aos Arquivos do Celular (Regra de Negócio Crítica)
                      ListTile(
                        leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: const Color(0xFF34C759)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.folder_special,
                                color: Color(0xFF34C759), size: 20)),
                        title: Text('Acesso Automático',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: textColor,
                                fontSize: 14)),
                        subtitle: Text('Ler PDFs e Docs do dispositivo',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500])),
                        trailing: Switch(
                          activeThumbColor: const Color(0xFF2E6AD4),
                          value: provider.permissaoAcessoArquivos,
                          onChanged: (val) {
                            if (val) {
                              // Se for ligar, pede a permissão normalmente
                              provider.alternarPermissaoArquivos(true);
                            } else {
                              // Se for desligar, exige confirmação para evitar perdas acidentais
                              _confirmarRevogacao(context, provider);
                            }
                          },
                        ),
                      ),
                      Divider(
                          height: 1,
                          indent: 60,
                          endIndent: 16,
                          color: isDark ? Colors.grey[800] : Colors.grey[100]),
                      // Switch do Modo Escuro
                      ListTile(
                        leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: const Color(0xFFAF52DE)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.dark_mode_outlined,
                                color: Color(0xFFAF52DE), size: 20)),
                        title: Text('Modo Escuro',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: textColor,
                                fontSize: 14)),
                        subtitle: Text('Alterar tema visual',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500])),
                        trailing: Switch(
                          activeThumbColor: const Color(0xFF2E6AD4),
                          value: provider.isDarkMode,
                          onChanged: (val) => provider.toggleTheme(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            Column(
              children: [
                const Divider(color: Colors.black12),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () => _mostrarSobreApp(context),
                        child: const Text('Sobre o App',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13))),
                  ],
                ),
                const Text('DocScanner v1.0.0',
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPerfilCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1A3A6B), Color(0xFF2E6AD4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(28)),
              child: const Icon(Icons.person, color: Colors.white, size: 30)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Olá, bem-vindo!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('DocScanner · Plano Gratuito',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}