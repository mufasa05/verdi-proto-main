import 'package:flutter_test/flutter_test.dart';
import 'package:verdi/state/platform_data_state.dart';

void main() {
  test('updatePayment changes status and note for a payment', () {
    final notifier = PaymentsNotifier();

    notifier.updatePayment(
      '#PAY-1001',
      status: 'Completed',
      note: 'Settled through instant transfer',
      riskLevel: 'Low',
      settlementWindow: 'Instant',
      destination: 'Harare Wallet',
      timeline: ['Initiated', 'Captured', 'Settled'],
    );

    final payment = notifier.state.firstWhere((p) => p.id == '#PAY-1001');

    expect(payment.status, 'Completed');
    expect(payment.note, 'Settled through instant transfer');
    expect(payment.riskLevel, 'Low');
    expect(payment.settlementWindow, 'Instant');
    expect(payment.destination, 'Harare Wallet');
    expect(payment.timeline, ['Initiated', 'Captured', 'Settled']);
  });
}
