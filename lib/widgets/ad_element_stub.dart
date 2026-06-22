import 'package:flutter/material.dart';

class AdSenseWidget extends StatelessWidget {
  const AdSenseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 웹 환경이 아닐 때는 광고 영역을 비워두거나 작은 플레이스홀더를 제공합니다.
    return const SizedBox.shrink();
  }
}
