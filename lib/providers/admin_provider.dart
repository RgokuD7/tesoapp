/* import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'group_provider.dart';
import 'user_provider.dart';


final isAdminProvider = Provider<bool>((ref) {
  final userNotifier = ref.watch(userProvider.notifier);
  final group = ref.watch(groupProvider);

  userNotifier.getUser(group.admin);
});
 */