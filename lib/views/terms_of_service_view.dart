import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "이용약관",
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "스도쿠 가든 이용약관",
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "시행일: 2026년 3월 19일",
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const Divider(color: Colors.white10, height: 40),
            _buildSection(
              "제 1 조 (목적)",
              "본 약관은 '스도쿠 가든'(이하 '서비스')이 제공하는 모든 서비스의 이용 조건 및 절차, 이용자와 서비스 제공자 간의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.",
            ),
            _buildSection(
              "제 2 조 (용어의 정의)",
              "1. '서비스'란 스도쿠 퍼즐과 RPG 요소가 결합된 웹/앱 애플리케이션을 의미합니다.\n2. '이용자'란 본 약관에 따라 서비스를 이용하는 모든 사용자를 의미합니다.",
            ),
            _buildSection(
              "제 3 조 (약관의 효력 및 변경)",
              "1. 본 약관은 서비스 화면에 게시함으로써 효력이 발생합니다.\n2. 서비스 제공자는 필요한 경우 관련 법령을 위배하지 않는 범위 내에서 약관을 변경할 수 있으며, 변경된 약관은 공지사항을 통해 고지합니다.",
            ),
            _buildSection(
              "제 4 조 (서비스 이용 및 제한)",
              "1. 이용자는 서비스가 제공하는 퍼즐, 도감, 전투 시스템 등을 자유롭게 이용할 수 있습니다.\n2. 타인의 이용을 방해하거나 시스템에 위해를 가하는 행위, 부정한 방법으로 데이터를 조작하는 행위 등은 이용이 제한될 수 있습니다.",
            ),
            _buildSection(
              "제 5 조 (지식재산권)",
              "1. 서비스 내의 모든 콘텐츠(텍스트, 이미지, 로직, 디자인 등)에 대한 저작권 및 지식재산권은 서비스 제공자에게 귀속됩니다.\n2. 이용자는 서비스를 이용함으로써 얻은 정보를 사전 승낙 없이 복제, 송신, 출판, 배포할 수 없습니다.",
            ),
            _buildSection(
              "제 6 조 (책임의 한계)",
              "1. 서비스 제공자는 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스 제공에 관한 책임이 면제됩니다.\n2. 이용자의 귀책 사유로 인한 서비스 이용 장애에 대하여는 책임을 지지 않습니다.",
            ),
            _buildSection(
              "제 7 조 (관할 법원)",
              "서비스 이용과 관련하여 발생한 분쟁에 대해 소송이 제기될 경우, 서비스 제공자의 본사 소재지를 관할하는 법원을 전용 관할 법원으로 합니다.",
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white70,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("확인 및 돌아가기"),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
