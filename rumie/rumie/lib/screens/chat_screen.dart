import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../di/locator.dart';
import '../domain/entities/entities.dart';
import '../domain/errors/error_messages.dart';
import '../domain/repositories/conversations_repository.dart';
import '../models/message.dart';
import '../state/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';
import '../widgets/avatar_style.dart';
import '../widgets/match_tile.dart';
import '../widgets/state_views.dart';
import '../widgets/ui/circle_button.dart';
import '../widgets/ui/photo.dart';

class ChatScreen extends StatefulWidget {
  final MatchSummary match;
  const ChatScreen({super.key, required this.match});

  static Route<void> route(MatchSummary m) => MaterialPageRoute(builder: (_) => ChatScreen(match: m));

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
      final sent = await locator<ConversationsRepository>().sendMessage(_convId, text);
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
        SnackBar(content: Text(fieldMsg ?? userMessage(e, fallback: "Couldn't send your message."))),
      );
    }
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
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final m = widget.match;
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
          Avatar(path: _style.asset, name: m.title, size: 42, tint: _style.gradient, heroTag: MatchTile.heroTag(m)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title, style: AppText.tileTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(m.subtitle, style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    final m = widget.match;
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Avatar(path: _style.asset, name: m.title, size: 96, tint: _style.gradient)
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.9, 0.9), curve: AppMotion.enter, duration: 500.ms),
            const SizedBox(height: 18),
            Text(m.title, style: AppText.sectionTitle).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 6),
            Text('Say hi 👋', style: AppText.secondary).animate().fadeIn(delay: 180.ms),
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
            .scale(
              begin: const Offset(0.94, 0.94),
              alignment: msg.isMe ? Alignment.bottomRight : Alignment.bottomLeft,
              duration: 320.ms,
              curve: AppMotion.enter,
            )
            .slideY(begin: 0.2, duration: 320.ms, curve: AppMotion.enter);
      },
    );
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
                decoration: const InputDecoration(
                  hintText: 'Message',
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
              final canSend = value.text.trim().isNotEmpty && !_sending;
              return AnimatedScale(
                scale: canSend ? 1 : 0.9,
                duration: AppMotion.of(context, AppMotion.base),
                curve: AppMotion.enter,
                child: AnimatedOpacity(
                  opacity: canSend || _sending ? 1 : 0.5,
                  duration: AppMotion.of(context, AppMotion.base),
                  child: _sending
                      ? SizedBox(
                          width: 46,
                          height: 46,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.accent),
                            ),
                          ),
                        )
                      : CircleButton(
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
