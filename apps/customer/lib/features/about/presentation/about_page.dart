import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:lenlab_customer/app/customer_scope.dart';
import 'package:lenlab_customer/app/navigation.dart';
import 'package:lenlab_customer/shared/widgets/header_widgets.dart';

import '../data/about_source.dart';
import 'widgets/about_hero.dart';
import 'widgets/about_values.dart';
import 'widgets/about_timeline.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key, this.source});
  final AboutSource? source;
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  AboutSource? source;
  Future<AboutContent?>? request;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    source ??=
        widget.source ?? MockAboutSource(CustomerScope.of(context).repository);
    request ??= source!.load();
  }

  void retry() => setState(() {
    request = source!.load();
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 72,
      automaticallyImplyLeading: false,
      leadingWidth: 72,
      leading: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: HeaderBackButton(),
      ),
      title: const Text('Giới thiệu'),
      actions: const [SizedBox(width: 72)],
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => go(context, '/products'),
          style: ElevatedButton.styleFrom(
            backgroundColor: P2.authButton,
            foregroundColor: const Color(0xFF523A30),
            elevation: 4,
            shadowColor: Colors.black26,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: const StadiumBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(
                child: Text(
                  'Khám phá sản phẩm',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              P2Asset.node(
                '2026:3774',
                'imgContainer4',
                width: 13.333,
                height: 13.333,
              ),
            ],
          ),
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      bottom: false,
      child: FutureBuilder<AboutContent?>(
        future: request,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Đang tải giới thiệu',
              ),
            );
          }
          if (snapshot.hasError) {
            return EmptyPanel(
              'Không thể tải giới thiệu',
              action: P2Button('Thử lại', onPressed: retry),
            );
          }
          final content = snapshot.data;
          if (content == null) {
            return EmptyPanel(
              'Nội dung giới thiệu đang được cập nhật',
              action: P2Button('Thử lại', onPressed: retry),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AboutHero(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Xin chào, chúng mình là LENLAB',
                        style: TextStyle(
                          fontSize: 20,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                          color: P2.brown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        content.introduction,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 26 / 16,
                          color: P2.brown,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const AboutValues(),
                const SizedBox(height: 32),
                const _SectionTitle('Tầm nhìn & Sứ mệnh'),
                const SizedBox(height: 16),
                AboutPurposeCard(
                  title: 'Tầm nhìn',
                  text: content.vision,
                  vision: true,
                ),
                const SizedBox(height: 16),
                AboutPurposeCard(
                  title: 'Sứ mệnh',
                  text: content.mission,
                  vision: false,
                ),
                const SizedBox(height: 32),
                const _SectionTitle('Hành trình phát triển'),
                const SizedBox(height: 24),
                AboutTimeline(content: content),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 22,
      height: 1.25,
      letterSpacing: -.33,
      fontWeight: FontWeight.w700,
      color: P2.brown,
    ),
  );
}
