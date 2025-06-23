import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loja de Eletrônicos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const PrincipalPage(),
    );
  }
}

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage>
    with SingleTickerProviderStateMixin {
  int _indiceSelecionado = 0;
  late TabController _tabController;

  final List<String> categorias = [
    'Início',
    'Headsets',
    'Teclados',
    'Notebooks',
    'Placas de Vídeo',
    'Gabinetes',
    'Mouses',
  ];

  final Map<String, List<Produto>> categoriasMap = {};

  List<Produto> carrinho = [];
  List<Produto> favoritos = [];

  bool _isPesquisando = false;
  String _textoPesquisa = '';

  @override
  void initState() {
    super.initState();
    for (var categoria in categorias) {
      if (categoria == 'Início') {
        categoriasMap[categoria] = _produtos;
      } else {
        categoriasMap[categoria] = _produtos
            .where((p) => p.categoria == categoria)
            .toList();
      }
    }
    _tabController = TabController(length: categorias.length, vsync: this);
    _tabController.addListener(() {
      if (_indiceSelecionado == 0) {
        setState(() {
          // Atualiza a tela ao trocar abas
        });
      }
    });
  }

  void adicionarAoCarrinho(Produto p) {
    setState(() {
      carrinho.add(p);
    });
  }

  void removerDoCarrinho(Produto p) {
    setState(() {
      carrinho.remove(p);
    });
  }

  void toggleFavorito(Produto p) {
    setState(() {
      if (favoritos.contains(p)) {
        favoritos.remove(p);
      } else {
        favoritos.add(p);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget corpo;

    if (_indiceSelecionado == 0) {
      final produtosExibidos = _textoPesquisa.isEmpty
          ? categoriasMap[categorias[_tabController.index]] ?? []
          : (categoriasMap[categorias[_tabController.index]] ?? [])
                .where(
                  (p) => p.nome.toLowerCase().contains(
                    _textoPesquisa.toLowerCase(),
                  ),
                )
                .toList();

      corpo = Column(
        children: [
          Material(
            color: Colors.purple,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: categorias.map((c) => Tab(text: c)).toList(),
            ),
          ),
          Expanded(
            child: produtosExibidos.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum produto nesta categoria',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : GridView.count(
                    padding: const EdgeInsets.all(12),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: produtosExibidos
                        .map(
                          (produto) => ProdutoCard(
                            nome: produto.nome,
                            preco: produto.preco,
                            imagemUrl: produto.imagemUrl,
                            isFavorito: favoritos.contains(produto),
                            onAddToCart: () => adicionarAoCarrinho(produto),
                            onToggleFavorito: () => toggleFavorito(produto),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      );
    } else if (_indiceSelecionado == 1) {
      corpo = favoritos.isEmpty
          ? const Center(
              child: Text(
                'Nenhum favorito ainda',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : GridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: favoritos
                  .map(
                    (produto) => ProdutoCard(
                      nome: produto.nome,
                      preco: produto.preco,
                      imagemUrl: produto.imagemUrl,
                      isFavorito: true,
                      onAddToCart: () => adicionarAoCarrinho(produto),
                      onToggleFavorito: () => toggleFavorito(produto),
                    ),
                  )
                  .toList(),
            );
    } else {
      corpo = const UsuarioPage();
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: _indiceSelecionado == 0
            ? _isPesquisando
                  ? TextField(
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Buscar produtos...',
                        hintStyle: TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                      ),
                      onChanged: (valor) {
                        setState(() {
                          _textoPesquisa = valor;
                        });
                      },
                    )
                  : const Text('Runnan Market!')
            : _indiceSelecionado == 1
            ? const Text('Favoritos')
            : const Text('Usuário'),
        centerTitle: true,
        actions: [
          if (_indiceSelecionado == 0)
            IconButton(
              iconSize: 36,
              icon: Icon(_isPesquisando ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  if (_isPesquisando) {
                    _textoPesquisa = '';
                  }
                  _isPesquisando = !_isPesquisando;
                });
              },
            ),
          if (_indiceSelecionado != 2)
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CarrinhoPage(
                          carrinho: carrinho,
                          removerDoCarrinho: removerDoCarrinho,
                        ),
                      ),
                    );
                  },
                ),
                if (carrinho.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        carrinho.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: corpo,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[850],
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: _indiceSelecionado,
        onTap: (i) {
          setState(() {
            _indiceSelecionado = i;
            _isPesquisando = false;
            _textoPesquisa = '';
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Usuário'),
        ],
      ),
    );
  }
}

class Produto {
  final String nome;
  final String preco;
  final String imagemUrl;
  final String categoria;

  Produto({
    required this.nome,
    required this.preco,
    required this.imagemUrl,
    required this.categoria,
  });
}

final List<Produto> _produtos = [
  Produto(
    nome: 'Headset Havit Pink',
    preco: 'R\$161',
    imagemUrl: 'https://m.media-amazon.com/images/I/61paInMrBkL._AC_SX679_.jpg',
    categoria: 'Headsets',
  ),
  Produto(
    nome: 'Headset Razer Kraken Blue',
    preco: 'R\$508',
    imagemUrl: 'https://m.media-amazon.com/images/I/71wTWDFWWXL._AC_SX679_.jpg',
    categoria: 'Headsets',
  ),
  Produto(
    nome: 'Headset Razer Kraken Pink',
    preco: 'R\$850',
    imagemUrl: 'https://m.media-amazon.com/images/I/61PNV4zVQKL._AC_SX679_.jpg',
    categoria: 'Headsets',
  ),
  Produto(
    nome: 'HyperX Teclado',
    preco: 'R\$229,99',
    imagemUrl: 'https://m.media-amazon.com/images/I/51IQ2qI3cdL._AC_SX679_.jpg',
    categoria: 'Teclados',
  ),
  Produto(
    nome: 'Teclado Huntsman Razer',
    preco: 'R\$2.360,00',
    imagemUrl:
        'https://br.octoshop.com/cdn/shop/files/razer_huntsman_v3_pro_mini_black_10.jpg?v=1739279999',
    categoria: 'Teclados',
  ),
  Produto(
    nome: 'Teclado Compacto Redragon',
    preco: 'R\$210,00',
    imagemUrl:
        'https://cdn.awsli.com.br/2500x2500/1318/1318167/produto/169306870/be605c959c.jpg',
    categoria: 'Teclados',
  ),
  Produto(
    nome: 'Notebook Lenovo IdeaPad',
    preco: 'R\$2.449,90',
    imagemUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTALqqLipLgV2Seom-XO39BTA5WB7qFnsOZA&s',
    categoria: 'Notebooks',
  ),
  Produto(
    nome: 'Notebook Gamer NAVE Estelar',
    preco: 'R\$10.635,99',
    imagemUrl:
        'https://t17208.vtexassets.com/arquivos/ids/169689/ESTELARGM6P_2.png?v=638828195850230000',
    categoria: 'Notebooks',
  ),
  Produto(
    nome: 'Placa de Vídeo Quadro T400',
    preco: 'R\$1.384,90',
    imagemUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkasZYWlX1Uy4G3vgGyD9zcAKe78ZdPHp9aA&s',
    categoria: 'Placas de Vídeo',
  ),
  Produto(
    nome: 'Placa Geforce RTX 4060',
    preco: 'R\$2.799,90',
    imagemUrl:
        'https://images.tcdn.com.br/img/img_prod/1288773/placa_de_video_8gb_gigabyte_geforce_rtx_4060_gddr6_647_1_4b8beb6ba47a1892bbc5bbc6871003c9.jpg',
    categoria: 'Placas de Vídeo',
  ),
  Produto(
    nome: 'GeForce RTX 4080 Asus',
    preco: 'R\$13.658,99',
    imagemUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTADNk1K33DmEhPyEIl6A7Rs1sDx9j-DfQkbw&s',
    categoria: 'Placas de Vídeo',
  ),
  Produto(
    nome: 'Gabinete NZXT H7 Flow',
    preco: 'R\$1.329,99',
    imagemUrl:
        'https://cdn.shoppub.io/cdn-cgi/image/w=1000,h=1000,q=80,f=auto/oficinadosbits/media/uploads/produtos/foto/pksiubwk/file.png',
    categoria: 'Gabinetes',
  ),
  Produto(
    nome: 'Gabinete Gamer Megalon',
    preco: 'R\$240,90',
    imagemUrl:
        'https://images.tcdn.com.br/img/img_prod/406359/gabinete_gamer_mini_tower_mini_itx_matx_aco_e_vidro_preto_290x190x375mm_clanm_megalon_7967_1_3834405ee84353f1da11c602876f5911.jpg',
    categoria: 'Gabinetes',
  ),
  Produto(
    nome: 'Gabinete Concórdia Monster',
    preco: 'R\$575,10',
    imagemUrl:
        'https://images.tcdn.com.br/img/img_prod/740836/gabinete_gamer_concordia_monster_4_fans_argb_fonte_500w_80_plus_bronze_16109_1_cf3cdbf4047d49e563292d2000f3bb4b.png',
    categoria: 'Gabinetes',
  ),
  Produto(
    nome: 'Mouse Logitech M90',
    preco: 'R\$36,96',
    imagemUrl:
        'https://eletronicasantana.vteximg.com.br/arquivos/ids/101235-1000-1000/MOUSE-USB-OPTICO-1000DPI-PRETO-M90-LOGITECH-1.jpg?v=638042867318600000',
    categoria: 'Mouses',
  ),
  Produto(
    nome: 'Mouse Logitech G203',
    preco: 'R\$158,00',
    imagemUrl: 'https://m.media-amazon.com/images/I/61UxfXTUyvL.jpg',
    categoria: 'Mouses',
  ),
  Produto(
    nome: 'Mouse Fortrek Vickers',
    preco: 'R\$79,90',
    imagemUrl: 'https://static.mundomax.com.br/produtos/77246/100/1.webp',
    categoria: 'Mouses',
  ),
];

class ProdutoCard extends StatelessWidget {
  final String nome;
  final String preco;
  final String imagemUrl;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleFavorito;
  final bool isFavorito;

  const ProdutoCard({
    required this.nome,
    required this.preco,
    required this.imagemUrl,
    this.onAddToCart,
    this.onToggleFavorito,
    this.isFavorito = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Card(
        elevation: 4,
        color: Colors.grey[850],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              imagemUrl,
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                nome,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              preco,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onAddToCart,
                  child: const Text('Comprar'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isFavorito ? Icons.star : Icons.star_border,
                    color: isFavorito ? Colors.white : Colors.white,
                  ),
                  onPressed: onToggleFavorito,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class CarrinhoPage extends StatelessWidget {
  final List<Produto> carrinho;
  final void Function(Produto) removerDoCarrinho;

  const CarrinhoPage({
    required this.carrinho,
    required this.removerDoCarrinho,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body: carrinho.isEmpty
          ? const Center(child: Text('Carrinho vazio'))
          : ListView.builder(
              itemCount: carrinho.length,
              itemBuilder: (context, index) {
                final produto = carrinho[index];
                return ListTile(
                  leading: Image.network(
                    produto.imagemUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(produto.nome),
                  subtitle: Text(produto.preco),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      removerDoCarrinho(produto);
                      Navigator.of(context).pop(); // fecha para atualizar
                    },
                  ),
                );
              },
            ),
    );
  }
}

class UsuarioPage extends StatelessWidget {
  const UsuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Área do Usuário',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () {}, child: const Text('Login')),
            const SizedBox(height: 12),
            TextButton(onPressed: () {}, child: const Text('Cadastrar-se')),
          ],
        ),
      ),
    );
  }
}
