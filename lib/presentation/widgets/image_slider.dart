import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imagePaths;
  const ImageSlider({Key? key, required this.imagePaths}) : super(key: key);

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openLink(String urlString) async {
    // Certifique-se de que a URL esteja corretamente formatada
    final Uri url = Uri.parse(urlString);

    try {
      // Use o método launchUrl com as opções recomendadas
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      )) {
        throw Exception('Não foi possível abrir $url');
      }
    } catch (e) {
      debugPrint('Erro ao abrir o link: $e');
      // Mostre um snackbar para o usuário
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o link: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String youtubeUrl = 'https://www.youtube.com/@flashbackpassinhosederlibety';

    return Center(
      child: Container(
        width: 350,
        height: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Slider de imagens
              PageView.builder(
                controller: _pageController,
                itemCount: widget.imagePaths.length,
                itemBuilder: (context, index) {
                  final path = widget.imagePaths[index];

                  // Verifica se a imagem é a terceira (índice 2)
                  if (index == 2) {
                    return InkWell(
                      onTap: () => _openLink(youtubeUrl),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(path, fit: BoxFit.cover),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.play_arrow,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Image.asset(path, fit: BoxFit.cover);
                },
              ),

              // Indicadores (bolinhas) na parte inferior central
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.imagePaths.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 12 : 8,
                      height: _currentPage == index ? 12 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? Colors.white : Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}