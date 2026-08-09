import 'package:flutter/material.dart';
import '../../../../core/services/verdi_api_service.dart';

import 'embedded_sub_ai_stub.dart'
    if (dart.library.html) 'embedded_sub_ai_web.dart';

class EmbeddedSubAiView extends StatelessWidget {
  final String? url;
  const EmbeddedSubAiView({
    super.key,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    final targetUrl = url ?? '${VerdiApiService.instance.baseUrl}/assistant/chat';
    return getEmbeddedSubAiView(targetUrl);
  }
}
