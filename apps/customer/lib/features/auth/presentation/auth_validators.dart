String? requiredText(String? value) =>
    (value ?? '').trim().isEmpty ? 'Vui lòng nhập thông tin.' : null;

String? emailValidator(String? value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((value ?? '').trim())
    ? null
    : 'Email chưa đúng định dạng.';

String? phoneValidator(String? value) =>
    RegExp(r'^0\d{9}$').hasMatch((value ?? '').trim())
    ? null
    : 'Số điện thoại gồm 10 chữ số, bắt đầu bằng 0.';
