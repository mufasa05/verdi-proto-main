import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dedicated Sovereign Control Console: AI Systems & Backbone Tuning Studio
class AiBackboneControlPage extends StatefulWidget {
  const AiBackboneControlPage({super.key});

  @override
  State<AiBackboneControlPage> createState() => _AiBackboneControlPageState();
}

class _AiBackboneControlPageState extends State<AiBackboneControlPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const cardDark = Color(0xFF161E2E);
  static const cardBorder = Color(0xFF2D3748);
  static const accentGreen = Color(0xFF10B981);
  static const accentDanger = Color(0xFFEF4444);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGold = Color(0xFFF59E0B);
  static const textMuted = Color(0xFF94A3B8);

  // Model parameters
  double _confidenceFloor = 85.0;
  double _temperature = 0.2;
  double _maxTokens = 2048;
  bool _shonaVoiceEnabled = true;
  bool _ndebeleVoiceEnabled = true;
  bool _strictAgronomyGuardrails = true;
  bool _aiKillSwitched = false;
  String _selectedPersona = 'Verdi Agro Sovereign Expert';

  final List<String> _personaOptions = [
    'Verdi Agro Sovereign Expert',
    'Shona & Ndebele Local Advisor',
    'EUDR Compliance Auditor',
    'National Agronomy Inspector',
  ];

  final TextEditingController _systemPromptCtrl = TextEditingController(
    text: 'You are Verdi AI, an expert autonomous agronomist and sovereign agricultural officer for Southern Africa. Provide strict, EUDR-compliant, accurate crop disease diagnostic and floor price guidance.',
  );

  final List<Map<String, String>> _guardrailRules = [
    {'rule': 'Block non-verified chemical pesticide recommendations', 'status': 'ENFORCED'},
    {'rule': 'Verify EUDR polygon satellite proof before export endorsement', 'status': 'ENFORCED'},
    {'rule': 'Strict fallback to Shona/Ndebele audio if low literacy flag set', 'status': 'ENFORCED'},
    {'rule': 'Refuse market price predictions below GMB floor prices', 'status': 'ENFORCED'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _systemPromptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Assistant Persona & Backbone Control Studio',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure prompt guardrails, agronomy model parameters, vector index, and emergency kill-switches.',
                    style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (_aiKillSwitched ? accentDanger : accentGreen).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _aiKillSwitched ? accentDanger : accentGreen),
              ),
              child: Row(
                children: [
                  Icon(_aiKillSwitched ? Icons.error_outline : Icons.check_circle_outline, color: _aiKillSwitched ? accentDanger : accentGreen, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _aiKillSwitched ? 'AI BACKBONE HALTED' : 'AI BACKBONE ONLINE',
                    style: TextStyle(color: _aiKillSwitched ? accentDanger : accentGreen, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorder),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: accentGreen,
            labelColor: accentGreen,
            unselectedLabelColor: textMuted,
            tabs: const [
              Tab(text: 'Model Parameters & Persona'),
              Tab(text: 'Prompt Guardrails & Safety'),
              Tab(text: 'Vector DB & Satellite Embeddings'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 1050,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildParametersTab(),
              _buildGuardrailsTab(),
              _buildVectorDbTab(),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 1: MODEL PARAMETERS ---
  Widget _buildParametersTab() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Emergency Kill Switch Container
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _aiKillSwitched ? accentDanger : cardBorder, width: _aiKillSwitched ? 2 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EMERGENCY AI BACKBONE KILL-SWITCH', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: _aiKillSwitched ? accentDanger : Colors.white)),
                    const SizedBox(height: 2),
                    const Text('Immediately halt all LLM inference, satellite raster analysis, and voice synthesis streams.', style: TextStyle(color: textMuted, fontSize: 11)),
                  ],
                ),
              ),
              Switch(
                value: _aiKillSwitched,
                activeColor: accentDanger,
                onChanged: (v) {
                  setState(() => _aiKillSwitched = v);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(v ? 'AI Systems emergency halted platform-wide.' : 'AI Systems restored.'),
                      backgroundColor: v ? accentDanger : accentGreen,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Persona Selection & Speech Engines
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ACTIVE AI PERSONA & VOICE SPEECH ENGINE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: accentGreen, letterSpacing: 1.0)),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('AI Assistant Persona Baseline', style: TextStyle(color: textMuted, fontSize: 13)),
                  DropdownButton<String>(
                    value: _selectedPersona,
                    dropdownColor: cardDark,
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    items: _personaOptions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedPersona = v);
                    },
                  ),
                ],
              ),

              const Divider(color: cardBorder, height: 24),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Shona Speech Synthesis Engine', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: const Text('Local neural TTS for Shona voice responses', style: TextStyle(color: textMuted, fontSize: 11)),
                value: _shonaVoiceEnabled,
                activeColor: accentGreen,
                onChanged: (v) => setState(() => _shonaVoiceEnabled = v),
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Ndebele Speech Synthesis Engine', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: const Text('Local neural TTS for Ndebele voice responses', style: TextStyle(color: textMuted, fontSize: 11)),
                value: _ndebeleVoiceEnabled,
                activeColor: accentGreen,
                onChanged: (v) => setState(() => _ndebeleVoiceEnabled = v),
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Strict Agronomy & Chemical Guardrails', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: const Text('Enforce EPA/EUDR approved chemical pesticide checks', style: TextStyle(color: textMuted, fontSize: 11)),
                value: _strictAgronomyGuardrails,
                activeColor: accentBlue,
                onChanged: (v) => setState(() => _strictAgronomyGuardrails = v),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ACTIVE BACKBONE PIPELINE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: accentGreen, letterSpacing: 1.0)),
              const SizedBox(height: 14),
              _configRow('Primary Model Engine', 'Llama-3.2-Vision (Local GPU Node)'),
              const SizedBox(height: 10),
              _configRow('Cloud Fallback Provider', 'Verdi Enterprise Backend AI Service (Direct TLS)'),
              const SizedBox(height: 10),
              _configRow('Speech Inference', 'Shona & Ndebele Whisper V3 (Local Core)'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Parameter Sliders
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HYPERPARAMETER TUNING', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: accentBlue, letterSpacing: 1.0)),
              const SizedBox(height: 16),

              Text('Plant Pathology Diagnostic Floor: ${_confidenceFloor.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Slider(
                value: _confidenceFloor,
                min: 50.0,
                max: 99.0,
                divisions: 49,
                activeColor: accentGreen,
                onChanged: (v) => setState(() => _confidenceFloor = v),
              ),

              const SizedBox(height: 10),

              Text('Model Temperature: ${_temperature.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Slider(
                value: _temperature,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                activeColor: accentBlue,
                onChanged: (v) => setState(() => _temperature = v),
              ),

              const SizedBox(height: 10),

              Text('Max Response Token Limit: ${_maxTokens.toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Slider(
                value: _maxTokens,
                min: 512.0,
                max: 8192.0,
                divisions: 15,
                activeColor: accentGold,
                onChanged: (v) => setState(() => _maxTokens = v),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Persona System Prompt Editor
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SOVEREIGN SYSTEM PROMPT & PERSONA', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: accentGold, letterSpacing: 1.0)),
              const SizedBox(height: 12),
              TextField(
                controller: _systemPromptCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorder)),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('System prompt updated & propagated to GPU inference nodes.'), backgroundColor: accentGreen),
                    );
                  },
                  icon: const Icon(Icons.save_outlined, size: 16),
                  label: const Text('Publish Prompt Update'),
                  style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 2: GUARDRAILS ---
  Widget _buildGuardrailsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Prompt Guardrails & Safety Filter Rules', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ElevatedButton.icon(
                onPressed: _showAddGuardrailModal,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Rule'),
                style: ElevatedButton.styleFrom(backgroundColor: accentBlue, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          for (int i = 0; i < _guardrailRules.length; i++) ...[
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: accentGreen, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(_guardrailRules[i]['rule']!, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: accentGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
                    child: Text(_guardrailRules[i]['status']!, style: const TextStyle(color: accentGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- TAB 3: VECTOR DB ---
  Widget _buildVectorDbTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vector Database & Satellite Embedding Store', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text('Manage high-dimensional spatial embeddings for agricultural land inspection.', style: TextStyle(color: textMuted, fontSize: 12)),
          const SizedBox(height: 20),

          _configRow('Vector Store Index Type', 'ChromaDB HNSW Index (COSINE metric)'),
          const SizedBox(height: 10),
          _configRow('Indexed Farm Polygon Vectors', '142,890 High-Res Polygons'),
          const SizedBox(height: 10),
          _configRow('Copernicus Band Embedding Dimension', '1536 Float32 Vectors'),
          const SizedBox(height: 20),

          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Re-indexing spatial vector store...'), backgroundColor: accentBlue),
                  );
                },
                icon: const Icon(Icons.sync, size: 16),
                label: const Text('Re-Index Vector Store'),
                style: ElevatedButton.styleFrom(backgroundColor: accentBlue, foregroundColor: Colors.white),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vector cache flushed cleanly.'), backgroundColor: accentGreen),
                  );
                },
                icon: const Icon(Icons.cleaning_services, size: 16, color: accentGreen),
                label: const Text('Clear Vector Cache', style: TextStyle(color: accentGreen)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: accentGreen)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _configRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: textMuted, fontSize: 13)),
        Text(val, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  void _showAddGuardrailModal() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        title: const Text('Add Guardrail Safety Rule', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Enter safety rule description...', hintStyle: TextStyle(color: textMuted)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: textMuted))),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                setState(() {
                  _guardrailRules.add({'rule': ctrl.text, 'status': 'ENFORCED'});
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
            child: const Text('Add Rule'),
          ),
        ],
      ),
    );
  }
}
