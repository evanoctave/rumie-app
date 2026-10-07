import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/message.dart';
import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';
import '../widgets/match_tile.dart';
import '../widgets/ui/circle_button.dart';
import '../widgets/ui/photo.dart';

class ChatScreen extends StatefulWidget {
  final Roommate roommate;
  const ChatScreen({super.key, required this.roommate});

  static Route<void> route(Roommate r) => MaterialPageRoute(builder: (_) => ChatScreen(roommate: r));

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
    "I'm flexible on move-in dates. What works for you?",
    "Let me know when you're free to talk.",
  ];

  final _random = Random();

  @override
  void initState() {
    super.initState();
    _typingCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
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
          duration: AppMotion.slow,
          curve: AppMotion.standard,
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
    final r = widget.roommate;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          CircleButton(
            iconAsset: 'assets/icons/ic_back.svg',
            semanticLabel: 'Back',
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Avatar(path: r.avatarAsset, name: r.name, size: 42, tint: r.gradient, heroTag: MatchTile.heroTag(r)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.name, style: AppText.tileTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const _PulseDot(),
                    const SizedBox(width: 6),
                    Text('Active now', style: AppText.caption),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    final r = widget.roommate;
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Avatar(path: r.avatarAsset, name: r.name, size: 96, tint: r.gradient)
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.9, 0.9), curve: AppMotion.enter, duration: 500.ms),
            const SizedBox(height: 18),
            Text('Say hi to ${r.name}', style: AppText.sectionTitle).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 6),
            Text('You both want a place in the Bay.', style: AppText.secondary).animate().fadeIn(delay: 180.ms),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final prev = index > 0 ? _messages[index - 1] : null;
        final grouped = prev != null && prev.isMe == msg.isMe;
        return _Bubble(message: msg, grouped: grouped)
            .animate()
            .fadeIn(duration: 220.ms)
            .scale(begin: const Offset(0.94, 0.94), alignment: msg.isMe ? Alignment.bottomRight : Alignment.bottomLeft, duration: 320.ms, curve: AppMotion.enter)
            .slideY(begin: 0.2, duration: 320.ms, curve: AppMotion.enter);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(6),
              ),
              border: Border.all(color: AppColors.line),
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
                        offset: Offset(0, -3 * (off + 1) / 2),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: AppColors.textTertiary, shape: BoxShape.circle),
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
    ).animate().fadeIn(duration: 180.ms).slideY(begin: 0.3, duration: 260.ms, curve: AppMotion.enter);
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
              ),
              child: TextField(
                controller: _textCtrl,
                style: AppText.bodyMedium,
                maxLines: 4,
                minLines: 1,
                cursorColor: AppColors.accent,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Message ${widget.roommate.name}',
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _textCtrl,
            builder: (context, value, _) {
              final canSend = value.text.trim().isNotEmpty;
              return AnimatedScale(
                scale: canSend ? 1 : 0.9,
                duration: AppMotion.of(context, AppMotion.base),
                curve: AppMotion.enter,
                child: AnimatedOpacity(
                  opacity: canSend ? 1 : 0.5,
                  duration: AppMotion.of(context, AppMotion.base),
                  child: CircleButton(
                    size: 46,
                    iconAsset: 'assets/icons/ic_send.svg',
                    style: canSend ? CircleButtonStyle.accent : CircleButtonStyle.surface,
                    semanticLabel: 'Send',
                    onTap: canSend ? _send : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Message message;
  final bool grouped;
  const _Bubble({required this.message, required this.grouped});

  @override
  Widget build(BuildContext context) {
    final me = message.isMe;
    const big = Radius.circular(20);
    const small = Radius.circular(6);
    return Padding(
      padding: EdgeInsets.only(bottom: grouped ? 4 : 10),
      child: Row(
        mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: me ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: big,
                  topRight: big,
                  bottomLeft: me ? big : small,
                  bottomRight: me ? small : big,
                ),
                border: me ? null : Border.all(color: AppColors.line),
                boxShadow: me ? AppColors.accentGlow(0.18) : null,
              ),
              child: Text(
                message.text,
                style: AppText.bodyMedium.copyWith(color: me ? AppColors.onAccent : AppColors.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot();

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: AppColors.positive, shape: BoxShape.circle),
    );
    if (AppMotion.reduced(context)) return dot;
    return dot
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.15, 1.15), duration: 1100.ms, curve: Curves.easeInOut);
  }
}
