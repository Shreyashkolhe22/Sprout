import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import 'widgets/intro_page.dart';

/// Four swipeable pages; the last one asks for the user's name and signs in.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  /// Called with the entered name (or a friendly default).
  final ValueChanged<String> onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 4;

  final _controller = PageController();
  final _name = TextEditingController();
  int _page = 0;

  bool get _isLast => _page == _pageCount - 1;

  @override
  void dispose() {
    _controller.dispose();
    _name.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _next() {
    if (!_isLast) {
      _goToPage(_page + 1);
      return;
    }
    final name = _name.text.trim();
    widget.onFinished(name.isEmpty ? 'friend' : name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLast ? null : () => _goToPage(_pageCount - 1),
                  child: Text('Skip', style: AppText.heavy(15, weight: FontWeight.w700)),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    const IntroPage(
                      illustration: AppAssets.couch,
                      title: 'Stuck on\nthe couch?',
                      body: 'Big goals feel heavy. Tiny daily habits get you moving.',
                    ),
                    const IntroPage(
                      illustration: AppAssets.wake,
                      title: 'Tiny habits,\nbig streaks',
                      body: 'Pick a few small things you want to do every day. '
                          'Sprout keeps score.',
                    ),
                    const IntroPage(
                      illustration: AppAssets.checklist,
                      title: 'Check in.\nWatch it grow.',
                      body: 'Tick a habit off each day and your streak climbs. '
                          'Miss a day and it starts over.',
                    ),
                    IntroPage(
                      illustration: AppAssets.clipboard,
                      title: 'What should\nPip call you?',
                      extra: _NameField(controller: _name, onSubmitted: _next),
                    ),
                  ],
                ),
              ),
              _PageDots(count: _pageCount, current: _page),
              const SizedBox(height: 20),
              ChunkyButton(label: _isLast ? "Let's grow" : 'Next', onPressed: _next),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: 2.5),
        );

    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      maxLength: 24,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmitted(),
      style: AppText.heavy(20),
      decoration: InputDecoration(
        hintText: 'Your name',
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        enabledBorder: border(AppColors.ink),
        focusedBorder: border(AppColors.tangerine),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == current ? 26 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: i == current ? AppColors.tangerine : Colors.transparent,
              border: Border.all(color: AppColors.ink, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
      ],
    );
  }
}
