import 'package:flutter/material.dart';

import 'app/customer_app.dart';
import 'features/profile/data/avatar_picker_source.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  galleryAvatarPicker.startRecovery();
  runApp(CustomerApp());
}
