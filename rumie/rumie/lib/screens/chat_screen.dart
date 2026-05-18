import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          duration: 300.ms,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/ic_back.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(AppColors.text, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.roommate.gradient.first.withAlpha(80),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SvgPicture.asset(widget.roommate.avatarAsset, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.roommate.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .scaleXY(begin: 0.7, end: 1.3, duration: 1000.ms)
                        .then()
                        .scaleXY(begin: 1.3, end: 0.7, duration: 1000.ms),
                    const SizedBox(width: 4),
                    const Text(
                      'Active now',
                      style: TextStyle(fontSize: 11, color: AppColors.secondary),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ic_more.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
            ),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputBar(),
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
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: widget.roommate.gradient.first.withAlpha(60),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: SvgPicture.asset(widget.roommate.avatarAsset, fit: BoxFit.cover),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
            const SizedBox(height: 14),
            Text(
              "Matched with ${widget.roommate.name}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 5),
            const Text(
              "Say hi 👋",
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ).animate().fadeIn(delay: 250.ms),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final prevIsMe = index > 0 && _messages[index - 1].isMe == msg.isMe;
        return _Bubble(
          message: msg,
          roommate: widget.roommate,
          showAvatar: !msg.isMe && !prevIsMe,
        ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, duration: 200.ms, curve: Curves.easeOut);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: widget.roommate.gradient.first.withAlpha(60),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SvgPicture.asset(widget.roommate.avatarAsset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: AnimatedBuilder(
                    animation: _typingCtrl,
                    builder: (ctx, anim) {
                      final off = sin((_typingCtrl.value * 2 * pi) - (i * pi / 3));
                      return Transform.translate(
                        offset: Offset(0, -3 * (off + 1) / 2),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _textCtrl,
                    style: const TextStyle(color: AppColors.text, fontSize: 15),
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Message...',
                      hintStyle: TextStyle(color: AppColors.gray),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: InputBorder.none,
                      filled: false,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SendButton(onTap: _send),
            ],
          ),
        ),
      ),
    );
  }
}

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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120),
        lowerBound: 0.87, upperBound: 1.0, value: 1.0);
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/ic_send.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Message message;
  final Roommate roommate;
  final bool showAvatar;

  const _Bubble({required this.message, required this.roommate, required this.showAvatar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            SizedBox(
              width: 28,
              child: showAvatar
                  ? Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: roommate.gradient.first.withAlpha(60),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SvgPicture.asset(roommate.avatarAsset, fit: BoxFit.cover),
                      ),
                    )
                  : const SizedBox(),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: message.isMe ? AppColors.secondary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isMe ? 16 : 4),
                  bottomRight: Radius.circular(message.isMe ? 4 : 16),
                ),
                border: message.isMe ? null : Border.all(color: AppColors.border),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
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
