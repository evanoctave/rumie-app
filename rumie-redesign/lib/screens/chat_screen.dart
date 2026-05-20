import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    "Hey! So excited we matched 🎉",
    "What's your schedule like?",
    "I love that neighborhood too!",
    "We should definitely meet up and chat.",
    "What kind of music are you into?",
    "Do you cook a lot?",
    "That sounds great honestly.",
    "I'm flexible on move-in dates — what works for you?",
    "Let me know when you're free to talk 😊",
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
      if (mounted) _addTheirMessage("Hey! Looks like we matched 👋");
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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.text),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.roommate.gradient.first.withAlpha(80),
                  widget.roommate.gradient.last.withAlpha(40),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.roommate.gradient.first.withAlpha(80),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(widget.roommate.avatarAsset, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.roommate.name,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .scaleXY(begin: 0.6, end: 1.4, duration: 1000.ms)
                      .then()
                      .scaleXY(begin: 1.4, end: 0.6, duration: 1000.ms),
                  const SizedBox(width: 5),
                  Text(
                    'Active now',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary, size: 24),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildMessages() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.roommate.gradient.first.withAlpha(70),
                    widget.roommate.gradient.last.withAlpha(40),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.roommate.gradient.first.withAlpha(80),
                  width: 2,
                ),
                boxShadow: AppColors.cardShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(widget.roommate.avatarAsset, fit: BoxFit.contain),
                ),
              ),
            ).animate().scale(duration: 450.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text(
              'Matched with ${widget.roommate.name}',
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 6),
            Text(
              'Say hi 👋',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 260.ms),
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
        final prevIsMe = index > 0 && _messages[index - 1].isMe == msg.isMe;
        return _Bubble(
          message: msg,
          roommate: widget.roommate,
          showAvatar: !msg.isMe && !prevIsMe,
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .slideY(begin: 0.12, duration: 220.ms, curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.roommate.gradient.first.withAlpha(80),
                  widget.roommate.gradient.last.withAlpha(40),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: SvgPicture.asset(widget.roommate.avatarAsset, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: AnimatedBuilder(
                    animation: _typingCtrl,
                    builder: (ctx, _) {
                      final off = sin((_typingCtrl.value * 2 * pi) - (i * pi / 3));
                      return Transform.translate(
                        offset: Offset(0, -4 * (off + 1) / 2),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(160),
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
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: TextField(
                    controller: _textCtrl,
                    style: GoogleFonts.dmSans(color: AppColors.text, fontSize: 15),
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      hintStyle: GoogleFonts.dmSans(color: AppColors.gray, fontSize: 15),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _SendButton(onTap: _send),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Send button ────────────────────────────────────────────────────────────────

class _SendButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.86,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.buttonShadow,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/ic_send.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Chat bubble ────────────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final Message message;
  final Roommate roommate;
  final bool showAvatar;

  const _Bubble({required this.message, required this.roommate, required this.showAvatar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            SizedBox(
              width: 30,
              child: showAvatar
                  ? Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            roommate.gradient.first.withAlpha(80),
                            roommate.gradient.last.withAlpha(40),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: SvgPicture.asset(roommate.avatarAsset, fit: BoxFit.contain),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.68,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: message.isMe ? AppColors.primaryGradient : null,
                color: message.isMe ? null : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isMe ? 18 : 4),
                  bottomRight: Radius.circular(message.isMe ? 4 : 18),
                ),
                boxShadow: message.isMe
                    ? [BoxShadow(color: AppColors.primary.withAlpha(40), blurRadius: 12, offset: const Offset(0, 4))]
                    : AppColors.cardShadow,
              ),
              child: Text(
                message.text,
                style: GoogleFonts.dmSans(
                  fontSize: 14.5,
                  height: 1.45,
                  color: message.isMe ? Colors.white : AppColors.text,
                ),
              ),
            ),
          ),
          if (message.isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
