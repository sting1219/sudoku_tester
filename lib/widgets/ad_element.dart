import 'dart:js_interop';
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

      // 발급받으신 코드를 적용 (format을 horizontal로 고정하여 게임 화면 침범 방지)
      div.innerHTML = '''
        <ins class="adsbygoogle"
             style="display:block; width:100%; height:100%;"
             data-ad-client="ca-pub-3565697632228043"
             data-ad-slot="6362829331"
             data-ad-format="horizontal" 
             data-full-width-responsive="true"></ins>
        <script>
             (adsbygoogle = window.adsbygoogle || []).push({});
        </script>
      '''.toJS;

      return div;
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        // 모바일은 60px, 큰 화면(웹)은 90px 정도 공간 확보
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