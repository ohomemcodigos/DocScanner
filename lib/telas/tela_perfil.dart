import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/documentos_provider.dart';
import '../provedores/usuario_provider.dart';

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final docProvider = context.watch<DocumentosProvider>();
    final userProvider = context.watch<UsuarioProvider>();
    
    final isDark = docProvider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A3A6B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Perfil', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 24),
              
              userProvider.isLogado 
                  ? _buildCardPerfil(userProvider, cardColor, textColor, isDark)
                  : _buildCardLogin(context, userProvider, cardColor, textColor, isDark),

              const SizedBox(height: 32),
              Text('Configurações', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2)),
              const SizedBox(height: 16),

              // --- CORREÇÃO DO ERRO DO LIST TILE AQUI ---
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                // Usamos o widget Material para a cor de fundo, permitindo que a animação de toque funcione!
                child: Material(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias, // Evita que a animação passe dos cantos arredondados
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF2E6AD4).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFF2E6AD4), size: 22)
                        ),
                        title: Text('Modo Escuro', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
                        trailing: Switch(
                          value: isDark,
                          activeColor: const Color(0xFF2E6AD4),
                          onChanged: (val) => docProvider.toggleTheme(),
                        ),
                      ),
                      Divider(height: 1, indent: 64, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                      
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF00C48C).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.folder_shared, color: Color(0xFF00C48C), size: 22)
                        ),
                        title: Text('Busca Automática de Arquivos', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Permite ao DocScanner encontrar PDFs e documentos (Word, Excel) nas pastas do dispositivo. Ignora imagens e vídeos.', 
                            style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.3)
                          ),
                        ),
                        trailing: Switch(
                          value: docProvider.permissaoAcessoArquivos,
                          activeColor: const Color(0xFF00C48C),
                          onChanged: (val) => docProvider.alternarPermissaoArquivos(val),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text('Geral', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2)),
              const SizedBox(height: 16),

              // --- CORREÇÃO DO ERRO DO LIST TILE AQUI TAMBÉM ---
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Material(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.cleaning_services, color: Colors.orange, size: 22)
                        ),
                        title: Text('Limpar Cache', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: Text('Libera espaço de edições temporárias.', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cache de edição limpo com sucesso!'))
                          );
                        },
                      ),
                      Divider(height: 1, indent: 64, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                      
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.info_outline, color: isDark ? Colors.grey[400] : Colors.grey[700], size: 22)
                        ),
                        title: Text('Sobre o DocScanner', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () => _mostrarDialogoSobre(context, isDark, textColor),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),
              
              Center(
                child: Column(
                  children: [
                    Text('DocScanner', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('MVP [1.0.0]', style: TextStyle(color: Colors.grey[500], fontSize: 13, letterSpacing: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoSobre(BuildContext context, bool isDark, Color textColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4)
                  )
                ]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/logo.jpg', 
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain, 
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.document_scanner, 
                    size: 48, 
                    color: Color(0xFF2E6AD4)
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('DocScanner', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 8),
            Text('MVP [1.0.0]', style: TextStyle(fontSize: 12, color: Colors.grey[500], letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Text(
              'O DocScanner é uma ferramenta inteligente criada para simplificar a gestão e digitalização dos seus documentos. \n\n'
              'Transforme papéis em PDFs, organize ficheiros e leve o seu escritório no bolso.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], height: 1.5, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6AD4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12)
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Fechar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      )
    );
  }

  Widget _buildCardLogin(BuildContext context, UsuarioProvider userProvider, Color cardColor, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E6AD4).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF2E6AD4).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFF2E6AD4)),
          ),
          const SizedBox(height: 16),
          Text('Proteja os seus documentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 8),
          Text(
            'Inicie sessão com o Google para habilitar backups e manter os seus scans seguros na nuvem.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], height: 1.4),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                foregroundColor: textColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isDark ? Colors.transparent : Colors.grey[300]!)
                )
              ),
              onPressed: userProvider.carregando ? null : () => userProvider.loginComGoogle(),
              child: userProvider.carregando 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.g_mobiledata, size: 32), 
                        SizedBox(width: 8),
                        Text('Entrar com o Google', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCardPerfil(UsuarioProvider userProvider, Color cardColor, Color textColor, bool isDark) {
    String inicial = userProvider.nome?.isNotEmpty == true ? userProvider.nome![0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFF2E6AD4),
                child: Text(inicial, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userProvider.nome ?? 'Utilizador', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 4),
                    Text(userProvider.email ?? '', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF4B4B),
                side: const BorderSide(color: Color(0xFFFF4B4B)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: userProvider.carregando ? null : () => userProvider.fazerLogout(),
              child: userProvider.carregando 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF4B4B)))
                : const Text('Terminar Sessão', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}