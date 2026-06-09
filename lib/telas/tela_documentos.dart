import 'package:flutter/material.dart';

class TelaDocumentos extends StatefulWidget {
  const TelaDocumentos({super.key});

  @override
  State<TelaDocumentos> createState() => _TelaDocumentosState();
}

class _TelaDocumentosState extends State<TelaDocumentos>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_Documento> _documentos = [
    _Documento(
      nome: 'Contrato de Prestação',
      data: '05 Jun 2026',
      tamanho: '1,2 MB',
      paginas: 3,
      tipo: _TipoDoc.pdf,
      favorito: true,
      recente: true,
    ),
    _Documento(
      nome: 'Comprovante de Entrega',
      data: '04 Jun 2026',
      tamanho: '856 KB',
      paginas: 1,
      tipo: _TipoDoc.imagem,
      favorito: false,
      recente: true,
    ),
    _Documento(
      nome: 'Relatório Financeiro',
      data: '02 Jun 2026',
      tamanho: '3,4 MB',
      paginas: 8,
      tipo: _TipoDoc.pdf,
      favorito: true,
      recente: false,
    ),
    _Documento(
      nome: 'Documento Pessoal',
      data: '28 Mai 2026',
      tamanho: '620 KB',
      paginas: 2,
      tipo: _TipoDoc.imagem,
      favorito: false,
      recente: false,
    ),
    _Documento(
      nome: 'Nota Fiscal Eletrônica',
      data: '20 Mai 2026',
      tamanho: '410 KB',
      paginas: 1,
      tipo: _TipoDoc.pdf,
      favorito: true,
      recente: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLista(_documentos),
                _buildLista(_documentos.where((d) => d.recente).toList()),
                _buildLista(_documentos.where((d) => d.favorito).toList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2E6AD4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 20,
      title: const Text(
        'Documentos',
        style: TextStyle(
          color: Color(0xFF1A3A6B),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search, color: Color(0xFF1A3A6B), size: 26),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.filter_list, color: Color(0xFF1A3A6B), size: 26),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF2E6AD4),
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        indicatorColor: const Color(0xFF2E6AD4),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Todos'),
          Tab(text: 'Recentes'),
          Tab(text: 'Favoritos'),
        ],
      ),
    );
  }

  Widget _buildLista(List<_Documento> docs) {
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Nenhum documento',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) => _buildDocumentoCard(docs[index]),
    );
  }

  Widget _buildDocumentoCard(_Documento doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildDocIcon(doc.tipo),
        title: Text(
          doc.nome,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A3A6B),
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                doc.data,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                doc.tamanho,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${doc.paginas} ${doc.paginas == 1 ? 'pág.' : 'págs.'}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              doc.favorito ? Icons.star : Icons.star_border,
              color: doc.favorito ? const Color(0xFFFFB300) : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 4),
            Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildDocIcon(_TipoDoc tipo) {
    final isPdf = tipo == _TipoDoc.pdf;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isPdf
            ? const Color(0xFFFF3B30).withOpacity(0.1)
            : const Color(0xFF2E6AD4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
        color: isPdf ? const Color(0xFFFF3B30) : const Color(0xFF2E6AD4),
        size: 26,
      ),
    );
  }
}

class _Documento {
  final String nome;
  final String data;
  final String tamanho;
  final int paginas;
  final _TipoDoc tipo;
  final bool favorito;
  final bool recente;

  _Documento({
    required this.nome,
    required this.data,
    required this.tamanho,
    required this.paginas,
    required this.tipo,
    required this.favorito,
    required this.recente,
  });
}

enum _TipoDoc { pdf, imagem }
