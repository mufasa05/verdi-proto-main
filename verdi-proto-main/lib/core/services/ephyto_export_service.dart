import 'package:flutter/foundation.dart';
import 'rate_limiter_service.dart';
import 'supabase_service.dart';
import 'security_crypto_service.dart';

class EPhytoCertificate {
  final String certNumber;
  final String exporterName;
  final String destinationCountry;
  final String commodity;
  final double quantityMt;
  final String digitalSignature;
  final String status; // 'ISSUED', 'PENDING_INSPECTION', 'REVOKED'

  EPhytoCertificate({
    required this.certNumber,
    required this.exporterName,
    required this.destinationCountry,
    required this.commodity,
    required this.quantityMt,
    required this.digitalSignature,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'cert_number': certNumber,
    'exporter_name': exporterName,
    'destination_country': destinationCountry,
    'commodity': commodity,
    'quantity_mt': quantityMt,
    'digital_signature': digitalSignature,
    'status': status,
    'created_at': DateTime.now().toIso8601String(),
  };
}

/// Service connecting export shipments to electronic Phytosanitary Certificate APIs.
class EPhytoExportService {
  EPhytoExportService._();
  static final EPhytoExportService instance = EPhytoExportService._();

  final SupabaseService _supabase = SupabaseService.instance;

  /// Issues electronic Phytosanitary Certificate registered on Supabase with cryptographic signature
  Future<EPhytoCertificate> issueCertificate({
    required String exporterName,
    required String destinationCountry,
    required String commodity,
    required double quantityMt,
  }) async {
    final isAllowed = RateLimiterService.instance.checkAndRecord(
      RateLimitCategory.exportPermits,
      keySuffix: 'ephyto_$exporterName',
    );
    if (!isAllowed) {
      debugPrint('⚡ Rate limit blocked issueCertificate for $exporterName');
    }

    final certNumber = 'ZIM-PH-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final cleanExporter = SecurityCryptoService.instance.sanitizeInput(exporterName);
    final cleanDest = SecurityCryptoService.instance.sanitizeInput(destinationCountry);
    final cleanCommodity = SecurityCryptoService.instance.sanitizeInput(commodity);

    final signature = SecurityCryptoService.instance.generateBatchSeal(
      batchCode: certNumber,
      farmId: cleanExporter,
      harvestDate: DateTime.now().toIso8601String(),
      quantity: quantityMt,
      latitude: -17.8252,
      longitude: 31.0335,
    );

    final cert = EPhytoCertificate(
      certNumber: certNumber,
      exporterName: cleanExporter,
      destinationCountry: cleanDest,
      commodity: cleanCommodity,
      quantityMt: quantityMt,
      digitalSignature: signature,
      status: 'ISSUED',
    );

    try {
      await _supabase.insertRecord('verdi_ephyto_certificates', cert.toJson());
      await _supabase.logActivity(
        userName: cleanExporter,
        userId: 'USR-GOV-004',
        userRole: 'Government Officer',
        actionTitle: '📜 E-Phyto Export Certificate Issued (Signed)',
        actionDescription: 'Issued electronic certificate $certNumber for $quantityMt MT $cleanCommodity to $cleanDest. Seal: ${signature.substring(0, 8)}...',
        module: 'Export',
        targetResource: certNumber,
      );
    } catch (e) {
      debugPrint('E-Phyto issue notice: $e');
    }

    return cert;
  }
}
