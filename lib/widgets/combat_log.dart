import 'package:flutter/material.dart';

class CombatLog extends StatefulWidget {
  final List<String> logMessages;

  const CombatLog({
    super.key,
    required this.logMessages,
  });

  @override
  State<CombatLog> createState() => _CombatLogState();
}

class _CombatLogState extends State<CombatLog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant CombatLog oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Scroll to bottom when new messages are added
    if (widget.logMessages.length > oldWidget.logMessages.length) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Fixed height for the log window
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.logMessages.length,
        itemBuilder: (context, index) {
          return Text(
            widget.logMessages[index],
            style: TextStyle(
              color: Colors.white.withAlpha((255 * 0.8).round()),
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
