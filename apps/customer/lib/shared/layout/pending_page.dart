import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../app/navigation.dart';
import '../widgets/header_widgets.dart';

class PendingPage extends StatelessWidget {
  const PendingPage({super.key, required this.route});
  final String route;
  @override
  Widget build(BuildContext context) {
    final content = switch (route) {
      '/customs' => (
        name: 'Đặt làm theo yêu cầu',
        title: 'Chưa thể gửi yêu cầu đặt làm',
        description: 'Tính năng đặt sản phẩm theo yêu cầu đang được chuẩn bị. Hiện chưa thể gửi yêu cầu hoặc nhận báo giá tại đây.',
      ),
      '/chat' => (
        name: 'Trợ lý LENLAB',
        title: 'Trợ lý chưa khả dụng',
        description: 'Trò chuyện và công cụ ước tính lượng len đang được chuẩn bị. Hiện chưa thể gửi tin nhắn hoặc nhận tư vấn tại đây.',
      ),
      '/policies' => (
        name: 'Chính sách LENLAB',
        title: 'Nội dung đang được hoàn thiện',
        description:
            'Hiện chưa có nội dung chính sách được công bố trên màn hình này.',
      ),
      _ => (
        name: 'LENLAB',
        title: 'Không tìm thấy trang',
        description: 'Trang bạn muốn mở hiện chưa có. Vui lòng quay lại hoặc về trang chủ.',
      ),
    };
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.textScalerOf(context).scale(18) > 18
            ? 80
            : 64,
        title: Text(
          content.name,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leadingWidth: 72,
        leading: Navigator.canPop(context)
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: HeaderBackButton(),
              )
            : null,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: EmptyPanel(
            content.title,
            description: content.description,
            action: P2Button('Về trang chủ', onPressed: () => home(context)),
          ),
        ),
      ),
    );
  }
}
