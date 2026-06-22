import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class AdSenseWidget extends StatelessWidget {
  const AdSenseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const String viewType = 'sudoku-bottom-ads';

    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final web.HTMLDivElement div = web.document.createElement('div') as web.HTMLDivElement;
      
      div.style
        ..width = '100%'
        ..height = '100%'
        ..display = 'flex'
        ..justifyContent = 'center';

      final web.HTMLElement ins = web.document.createElement('ins') as web.HTMLElement;
      ins.className = 'adsbygoogle';
      ins.style.display = 'block';
      ins.style.width = '100%';
      ins.style.height = '100%';
      ins.dataset['adClient'] = 'ca-pub-3565697632228043';
      ins.dataset['adSlot'] = '6362829331';
      ins.dataset['adFormat'] = 'horizontal';
      ins.dataset['fullWidthResponsive'] = 'true';

      final web.HTMLScriptElement script = web.document.createElement('script') as web.HTMLScriptElement;
      script.text = '(adsbygoogle = window.adsbygoogle || []).push({});';

      div.append(ins);
      div.append(script);

      return div;
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        double adHeight = constraints.maxWidth > 600 ? 90 : 60;
        
        return Container(
          width: double.infinity,
          height: adHeight,
          margin: const EdgeInsets.only(top: 5, bottom: 10),
          child: const HtmlElementView(viewType: viewType),
        );
      },
    );
  }
}
