import 'package:buddy_app/blocs/buddy/buddy_bloc.dart';
import 'package:buddy_app/constants/styles.dart';
import 'package:buddy_app/widgets/chat_bubble.dart';
import 'package:buddy_app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class PromptScreen extends StatefulWidget {
  const PromptScreen({Key? key}) : super(key: key);

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BuddyBloc, BuddyState>(
      listener: (context, state) async {
        if (state.isMicAvailable && state.isListening) {
          context.read<BuddyBloc>().add(BuddyStartListeningEvent());
        }

        if (state.mode == BuddyMode.speak && state.status != BuddyStatus.idle) {
          context.read<BuddyBloc>().add(BuddySendEvent());
        }
      },
      builder: (context, state) {
        return NotificationListener(
            onNotification: (notification) {
              if (state.status == BuddyStatus.busy) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController.position.correctPixels(
                    _scrollController.position.maxScrollExtent,
                  );
                  _scrollController.position.notifyListeners();
                });
              }

              if (state.deviceHeight + _scrollController.position.maxScrollExtent > state.deviceHeight &&
                  notification is ScrollMetricsNotification) {
                if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
                  context.read<BuddyBloc>().add(BuddySetScrollTop(canScrollTop: true));
                } else {
                  context.read<BuddyBloc>().add(BuddySetScrollTop(canScrollTop: false));
                }
              }
              return false;
            },
            child: SizeChangedLayoutNotifier(
              child: Scaffold(
                backgroundColor: primary,
                floatingActionButton: state.canScrollTop
                    ? FloatingActionButton(
                        backgroundColor: primary,
                        onPressed: () async {
                          context.read<BuddyBloc>().add(BuddySetScrollTop(canScrollTop: false));
                          await _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                          );
                        },
                        child: const Icon(Icons.arrow_upward),
                      )
                    : null,
                body: Container(
                  width: double.infinity,
                  padding: standardPadding,
                  child: Stack(
                    children: [
                      CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const VerticalSpace(),
                                SizedBox(
                                  height: 150,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              'Hello,\nI am your buddy',
                                              style: getStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                            ),
                                            const VerticalSpace(height: 8),
                                            Text(
                                              'What can I help you with?',
                                              style: getStyle(color: lightGrey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Image.asset('assets/buddy_avatar.png')
                                    ],
                                  ),
                                ),
                                const VerticalSpace(),
                                Column(
                                  children: state.prompt.entries
                                      .map((element) => Align(
                                          alignment: _isOdd(element.key) ? Alignment.centerRight : Alignment.centerLeft,
                                          child: ChatBubble(text: element.value, id: element.key)))
                                      .toList(),
                                ),
                                state.prompt.length > 4 ? const VerticalSpace(height: 200) : const VerticalSpace(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: state.mode != BuddyMode.listening
                              ? GestureDetector(
                                  onTap: () {
                                    if (state.mode != BuddyMode.speak) {
                                      context
                                          .read<BuddyBloc>()
                                          .add(BuddyCheckListenEvent(height: MediaQuery.of(context).size.height));
                                    }
                                  },
                                  child: Image.asset(
                                    'assets/mic_static.png',
                                    height: 100,
                                    width: 100,
                                  ),
                                )
                              : Lottie.asset('assets/mic_animation.json', height: 100, width: 100),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }

  bool _isOdd(int number) {
    return number % 2 != 0;
  }
}
