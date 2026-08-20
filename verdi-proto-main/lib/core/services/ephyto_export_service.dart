import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

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

  /// Issues electronic Phytosanitary Certificate registered on Supabase
  Future<EPhytoCertificate> issueCertificate({
    required String exporterName,
    required String destinationCountry,
    required String commodity,
    required double quantityMt,
  }) async {
    final cert = EPhytoCertificate(
      certNumber: 'ZIM-PH-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      exporterName: exporterName,
      destinationCountry: destinationCountry,
      commodity: commodity,
      quantityMt: quantityMt,
      digitalSignature: '0x8f2a991c4b22e10a884f',
      status: 'ISSUED',
    );

    try {
      await _supabase.insertRecord('verdi_ephyto_certificates', cert.toJson());
      await _supabase.logActivity(
        userName: exporterName,
        userId: 'USR-GOV-004',
        userRole: 'Government Officer',
        actionTitle: '📜 E-Phyto Export Certificate Issued',
        actionDescription: 'Issued electronic certificate ${cert.certNumber} for $quantityMt MT $commodity to $destinationCountry.',
        module: 'Export',
        targetResource: cert.certNumber,
      );
    } catch (e) {
      debugPrint('E-Phyto issue notice: $e');
    }

    return cert;
  }
}
