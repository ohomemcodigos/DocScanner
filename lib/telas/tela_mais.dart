import 'package:flutter/material.dart';

class TelaMais extends StatelessWidget {
  const TelaMais({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Mais',
          style: TextStyle(
            color: Color(0xFF1A3A6B),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPerfilCard(),
            const SizedBox(height: 20),
            _buildCompartilharCard(context),
            const SizedBox(height: 20),
            _buildSecao('Armazenamento', [
              _OpcaoItem(
                icon: Icons.cloud_upload_outlined,
                color: const Color(0xFF34C759),
                titulo: 'Google Drive',
                subtitulo: 'Sincronizar com Google Drive',
                onTap: () {},
              ),
              _OpcaoItem(
                icon: Icons.cloud_outlined,
                color: const Color(0xFF007AFF),
                titulo: 'Dropbox',
                subtitulo: 'Sincronizar com Dropbox',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 20),
            _buildSecao('Configurações', [
              _OpcaoItem(
                icon: Icons.notifications_outlined,
                color: const Color(0xFFFF9500),
                titulo: 'Notificações',
                subtitulo: 'Gerenciar alertas e lembretes',
                onTap: () {},
              ),
              _OpcaoItem(
                icon: Icons.lock_outline,
                color: const Color(0xFF1A3A6B),
                titulo: 'Privacidade',
                subtitulo: 'Bloqueio por senha ou biometria',
                onTap: () {},
              ),
              _OpcaoItem(
                icon: Icons.palette_outlined,
                color: const Color(0xFFAF52DE),
                titulo: 'Aparência',
                subtitulo: 'Tema claro ou escuro',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 20),
            _buildSecao('Suporte', [
              _OpcaoItem(
                icon: Icons.help_outline,
                color: const Color(0xFF2E6AD4),
                titulo: 'Ajuda e suporte',
                subtitulo: 'Perguntas frequentes e contato',
                onTap: () {},
              ),
              _OpcaoItem(
                icon: Icons.star_outline,
                color: const Color(0xFFFFB300),
                titulo: 'Avaliar o app',
                subtitulo: 'Deixe sua avaliação na loja',
                onTap: () {},
              ),
              _OpcaoItem(
                icon: Icons.info_outline,
                color: Colors.grey,
                titulo: 'Sobre',
                subtitulo: 'DocScanner v1.0.0',
                onTap: () {},
              ),
            ]),
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
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E6AD4).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, bem-vindo!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'DocScanner · Plano Gratuito',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompartilharCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compartilhar via',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3A6B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareOption(
                icon: Icons.message_outlined,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () {},
              ),
              _buildShareOption(
                icon: Icons.email_outlined,
                label: 'E-mail',
                color: const Color(0xFFEA4335),
                onTap: () {},
              ),
              _buildShareOption(
                icon: Icons.drive_file_move_outlined,
                label: 'Drive',
                color: const Color(0xFF34A853),
                onTap: () {},
              ),
              _buildShareOption(
                icon: Icons.share_outlined,
                label: 'Outros',
                color: const Color(0xFF2E6AD4),
                onTap: () {
                  _mostrarCompartilhar(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF1A3A6B)),
          ),
        ],
      ),
    );
  }

  Widget _buildSecao(String titulo, List<_OpcaoItem> opcoes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: opcoes.asMap().entries.map((entry) {
              final index = entry.key;
              final opcao = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: opcao.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(opcao.icon, color: opcao.color, size: 20),
                    ),
                    title: Text(
                      opcao.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A3A6B),
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      opcao.subtitulo,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onTap: opcao.onTap,
                  ),
                  if (index < opcoes.length - 1)
                    Divider(
                      height: 1,
                      indent: 60,
                      endIndent: 16,
                      color: Colors.grey[100],
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _mostrarCompartilhar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compartilhar documento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A3A6B),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.save_alt, color: Color(0xFF34C759)),
              title: const Text('Salvar em Google Drive'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download_outlined, color: Color(0xFF007AFF)),
              title: const Text('Salvar no Dropbox'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFF2E6AD4)),
              title: const Text('Outros aplicativos'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _OpcaoItem {
  final IconData icon;
  final Color color;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  _OpcaoItem({
    required this.icon,
    required this.color,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });
}
