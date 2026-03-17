import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "개인정보처리방침",
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "개인정보처리방침",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              "1. 수집하는 개인정보 항목",
              "본 앱은 사용자의 별도 회원가입 없이 이용 가능하며, 개인을 식별할 수 있는 정보를 직접적으로 수집하지 않습니다. 다만, 서비스 이용 과정에서 아래와 같은 정보들이 자동 생성되어 수집될 수 있습니다.\n- 단기적인 게임 진행 데이터 (기기 로컬 저장)\n- 기기 정보 (모델명, OS 버전)\n- 광고 식별자 (ADID/IDFA)",
            ),
            _buildSection(
              "2. 개인정보의 수집 및 이용 목적",
              "수집된 정보는 다음과 같은 목적으로 이용됩니다.\n- 게임 서비스 제공 및 데이터 저장\n- 서비스 개선 및 통계 분석\n- 광고 제공 및 맞춤형 콘텐츠 추천 (상용 광고 서비스 이용 시)",
            ),
            _buildSection(
              "3. 개인정보의 보유 및 이용 기간",
              "본 앱은 사용자 기기에 로컬로 데이터를 저장하며, 앱 삭제 시 해당 데이터는 함께 삭제됩니다. 광고 식별자 등의 정보는 광고 플랫폼의 정책에 따릅니다.",
            ),
            _buildSection(
              "4. 광고 서비스 이용에 따른 안내",
              "본 앱은 Google AdSense 및 AdMob 등 제3자 광고 서비스를 이용할 수 있습니다. 해당 서비스 제공업체는 맞춤형 광고를 제공하기 위해 쿠키나 광고 식별자를 사용할 수 있으며, 이에 대한 자세한 내용은 Google의 개인정보 보호 정책을 참조하시기 바랍니다.",
            ),
            _buildSection(
              "5. 사용자의 권리",
              "사용자는 언제든지 앱을 삭제함으로써 서비스 이용을 중단하고 로컬 데이터를 삭제할 수 있습니다. 기기 설정을 통해 광고 맞춤 설정 제안을 거부할 수도 있습니다.",
            ),
            _buildSection(
              "6. 문의처",
              "본 방침에 대한 문의사항이 있으시면 아래 연락처로 연락 주시기 바랍니다.\n이메일: support@example.com",
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                "시행 일자: 2024년 3월 12일",
                style: TextStyle(color: Colors.blueGrey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigoAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
