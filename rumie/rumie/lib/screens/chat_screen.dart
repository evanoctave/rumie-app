import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/message.dart';
import '../models/roommate.dart';
import '../theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  final Roommate roommate;
  const ChatScreen({super.key, required this.roommate});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<Message> _messages = [];
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isTyping = false;
  late AnimationController _typingCtrl;

  static const _responses = [
    "Hey! So excited we matched.",
    "What's your schedule like?",
    "I love that neighborhood too!",
    "We should definitely meet up and chat.",
    "What kind of music are you into?",
    "Do you cook a lot?",
    "That sounds great honestly.",
    "I'm flexible on move-in dates — what works for you?",
    "Let me know when you're free to talk.",
  ];

  final _random = Random();

  @override
  void initState() {
    super.initState();
    _typingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    Future.delayed(700.ms, () {
      if (mounted) _addTheirMessage('Hey! Looks like we matched.');
    });
  }

  @override
  void dispose() {
    _typingCtrl.dispose();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _addTheirMessage(String text) {
    setState(() {
      _isTyping = false;
      _messages.add(Message(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        isMe: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _send() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(Message(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        isMe: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _textCtrl.clear();
    _scrollToBottom();

    final delay = 1200 + _random.nextInt(1000);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _addTheirMessage(_responses[_random.nextInt(_responses.length)]);
    });
  }

  void _scrollToBottom() {
    Future.delayed(80.ms, () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: 280.ms,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildMessages()),
            if (_isTyping) _buildTypingIndicator(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              '←',
              style: GoogleFonts.syne(
                  fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.roommate.name.toUpperCase(),
              style: GoogleFonts.syne(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            'ACTIVE',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.green,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.roommate.name.toUpperCase(),
              style: GoogleFonts.syne(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -1.5,
              ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 8),
            Text(
              'Say hello.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ).animate().fadeIn(delay: 120.ms),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _Bubble(message: msg)
            .animate()
            .fadeIn(duration: 200.ms)
            .slideY(begin: 0.08, duration: 200.ms, curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.roommate.name[0].toUpperCase(),
              style: GoogleFonts.syne(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSoft, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedBuilder(
                    animation: _typingCtrl,
                    builder: (ctx, _) {
                      final off = sin((_typingCtrl.value * 2 * pi) - (i * pi / 3));
                      return Transform.translate(
                        offset: Offset(0, -4 * (off + 1) / 2),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 180.ms);
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: TextField(
                    controller: _textCtrl,
                    style: GoogleFonts.inter(color: AppColors.text, fontSize: 14),
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      hintStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.btnPrimary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '→',
                    style: GoogleFonts.syne(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.btnPrimaryText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Message message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.70,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: message.isMe ? AppColors.btnPrimary : AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: message.isMe
                    ? null
                    : Border.all(color: AppColors.borderSoft, width: 1),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.45,
                  color: message.isMe ? AppColors.btnPrimaryText : AppColors.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
