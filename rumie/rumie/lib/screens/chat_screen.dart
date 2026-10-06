import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';

import '../di/locator.dart';
import '../domain/entities/entities.dart';
import '../domain/errors/error_messages.dart';
import '../domain/repositories/conversations_repository.dart';
import '../models/message.dart';
import '../state/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar_style.dart';
import '../widgets/state_views.dart';

class ChatScreen extends StatefulWidget {
  final MatchSummary match;
  const ChatScreen({super.key, required this.match});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  bool _loading = true;
  bool _sending = false;
  String? _error;
  Timer? _poll;

  late final AvatarStyle _style = AvatarStyle.forId(widget.match.id);

  /// The API has no push channel; poll while the chat is open.
  static const _pollInterval = Duration(seconds: 5);

  String get _convId => widget.match.conversation.id;

  @override
  void initState() {
    super.initState();
    _load();
    _poll = Timer.periodic(_pollInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Message _toMessage(MessageOut m, String? myId) => Message(
        id: m.id,
        text: m.body,
        isMe: m.senderId == myId,
        timestamp: m.ts,
      );

  Future<void> _load() async {
    // Already in the loading state on first run (called from initState).
    if (!_loading) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      await _fetchAndMerge();
      if (!mounted) return;
      setState(() => _loading = false);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userMessage(e, fallback: "Couldn't load messages.");
        _loading = false;
      });
    }
  }

  /// Background poll; failures are silent (the next tick retries).
  Future<void> _refresh() async {
    if (_loading || _error != null || !mounted) return;
    try {
      final added = await _fetchAndMerge();
      if (added && mounted) _scrollToBottom();
    } catch (_) {}
  }

  /// Returns whether any new message arrived.
  Future<bool> _fetchAndMerge() async {
    final myId = context.read<AuthProvider>().user?.id;
    final page = await locator<ConversationsRepository>().listMessages(_convId);
    if (!mounted) return false;
    final known = _messages.map((m) => m.id).toSet();
    final fresh = page.where((m) => !known.contains(m.id)).toList();
    if (fresh.isEmpty) return false;
    setState(() {
      _messages
        ..addAll(fresh.map((m) => _toMessage(m, myId)))
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
    return true;
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    HapticFeedback.lightImpact();
    final myId = context.read<AuthProvider>().user?.id;
    setState(() => _sending = true);
    _textCtrl.clear();
    try {
      final sent =
          await locator<ConversationsRepository>().sendMessage(_convId, text);
      if (!mounted) return;
      setState(() {
        if (!_messages.any((m) => m.id == sent.id)) {
          _messages.add(_toMessage(sent, myId));
        }
        _sending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      // Give the text back so nothing typed is lost.
      if (_textCtrl.text.isEmpty) _textCtrl.text = text;
      setState(() => _sending = false);
      final fieldMsg = firstFieldError(fieldErrorsOf(e), 'body');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fieldMsg ?? userMessage(e, fallback: "Couldn't send your message."),
          ),
        ),
      );
    }
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
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.text),
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
                  _style.gradient.first.withAlpha(80),
                  _style.gradient.last.withAlpha(40),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _style.gradient.first.withAlpha(80),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(_style.asset, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.match.title,
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
          icon: Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary, size: 24),
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
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
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
                    _style.gradient.first.withAlpha(70),
                    _style.gradient.last.withAlpha(40),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _style.gradient.first.withAlpha(80),
                  width: 2,
                ),
                boxShadow: AppColors.cardShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(_style.asset, fit: BoxFit.contain),
                ),
              ),
            ).animate().scale(duration: 450.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text(
              'Matched with ${widget.match.title}',
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
          style: _style,
          showAvatar: !msg.isMe && !prevIsMe,
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .slideY(begin: 0.12, duration: 220.ms, curve: Curves.easeOutCubic);
      },
    );
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
              _SendButton(onTap: _send, busy: _sending),
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
  final bool busy;
  const _SendButton({required this.onTap, this.busy = false});

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
            child: widget.busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : SvgPicture.asset(
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
  final AvatarStyle style;
  final bool showAvatar;

  const _Bubble({required this.message, required this.style, required this.showAvatar});

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
                            style.gradient.first.withAlpha(80),
                            style.gradient.last.withAlpha(40),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: SvgPicture.asset(style.asset, fit: BoxFit.contain),
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
