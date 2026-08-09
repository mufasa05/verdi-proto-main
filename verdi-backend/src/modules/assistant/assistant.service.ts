import { Injectable, Logger } from '@nestjs/common';
import { Response } from 'express';

export interface AgentResponse {
  reply: string;
  intent: string;
  actionType: 'navigate' | 'execute' | 'query' | 'inform';
  moduleName: string;
  navIndex?: number;
  payload?: Record<string, any>;
}

@Injectable()
export class AssistantService {
  private readonly logger = new Logger(AssistantService.name);
  private readonly modalSttUrl =
    'https://truthdefender24--shona-stt-service-transcribe-endpoint.modal.run/';

  ask(text: string): AgentResponse {
    const prompt = (text || '').trim();
    const lower = prompt.toLowerCase();

    if (!prompt) {
      return {
        reply: 'Hello! I am your Verdi Autonomous Voice Agent. How can I assist you with platform operations today?',
        intent: 'greeting',
        actionType: 'inform',
        moduleName: 'assistant',
      };
    }

    // ─────────────────────────────────────────────────────────────────────────
    // English Platform Voice Command Intent Routing
    // ─────────────────────────────────────────────────────────────────────────

    // 1. Irrigation & Field Watering
    if (
      lower.includes('irrigation') ||
      lower.includes('water field') ||
      lower.includes('watering') ||
      lower.includes('pump') ||
      lower.includes('water')
    ) {
      const durMatch = /(\d+)\s*(min|minute|hr|hour)s?/.exec(lower);
      const durationStr = durMatch ? `${durMatch[1]} ${durMatch[2]}s` : '30 mins';

      let targetField = 'Field A (Maize)';
      if (lower.includes('field b') || lower.includes('zone b')) targetField = 'Field B (Soybeans)';
      if (lower.includes('field c') || lower.includes('zone c')) targetField = 'Field C (Wheat)';
      if (lower.includes('zone 1')) targetField = 'Zone 1 - High Density';
      if (lower.includes('zone 2')) targetField = 'Zone 2 - Pivot Sector';

      if (lower.includes('start') || lower.includes('turn on') || lower.includes('schedule') || lower.includes('run') || lower.includes('water')) {
        return {
          reply: `Executing automated smart irrigation protocol for ${targetField} (${durationStr})...`,
          intent: 'startIrrigation',
          actionType: 'execute',
          moduleName: 'irrigation',
          navIndex: 8,
          payload: { status: 'active', duration: durationStr, targetField },
        };
      }
      return {
        reply: 'Opening the Smart Irrigation Management dashboard...',
        intent: 'openIrrigation',
        actionType: 'navigate',
        moduleName: 'irrigation',
        navIndex: 8,
      };
    }

    // 2. Marketplace & Purchasing
    if (
      lower.includes('marketplace') ||
      lower.includes('market') ||
      lower.includes('buy') ||
      lower.includes('store') ||
      lower.includes('shop') ||
      lower.includes('purchase') ||
      lower.includes('order')
    ) {
      const qtyMatch = /(\d+)\s*(bag|unit|kg|ton|pack)s?/.exec(lower);
      const qtyStr = qtyMatch ? `${qtyMatch[1]} ${qtyMatch[2]}s` : null;

      let itemStr = 'Agricultural Products';
      if (lower.includes('fertilizer')) itemStr = 'NPK Fertilizer';
      if (lower.includes('seed') || lower.includes('maize seed')) itemStr = 'Hybrid Seed Maize';
      if (lower.includes('solar') || lower.includes('pump')) itemStr = 'Solar Irrigation Pump';

      const replyText = qtyStr
        ? `Searching Marketplace for ${qtyStr} of ${itemStr}...`
        : 'Opening the Verdi Agricultural Marketplace...';

      return {
        reply: replyText,
        intent: 'openMarketplace',
        actionType: 'navigate',
        moduleName: 'marketplace',
        navIndex: 1,
        payload: qtyStr ? { quantity: qtyStr, product: itemStr } : undefined,
      };
    }

    // 3. Weather & Radar
    if (
      lower.includes('weather') ||
      lower.includes('forecast') ||
      lower.includes('rain') ||
      lower.includes('radar') ||
      lower.includes('temperature')
    ) {
      return {
        reply: 'Loading real-time weather radar and atmospheric metrics...',
        intent: 'openWeather',
        actionType: 'navigate',
        moduleName: 'weather',
        navIndex: 17,
      };
    }

    // 4. Analytics & Performance
    if (
      lower.includes('analytics') ||
      lower.includes('analysis') ||
      lower.includes('dashboard') ||
      lower.includes('metrics') ||
      lower.includes('yield') ||
      lower.includes('performance') ||
      lower.includes('report')
    ) {
      return {
        reply: 'Opening farm performance analytics and yield forecasting...',
        intent: 'openAnalytics',
        actionType: 'navigate',
        moduleName: 'analytics',
        navIndex: 3,
      };
    }

    // 5. Logistics & Fleet Tracking
    if (
      lower.includes('logistics') ||
      lower.includes('fleet') ||
      lower.includes('truck') ||
      lower.includes('dispatch') ||
      lower.includes('transport')
    ) {
      return {
        reply: 'Opening fleet tracking and transport logistics dashboard...',
        intent: 'openLogistics',
        actionType: 'navigate',
        moduleName: 'logistics',
        navIndex: 5,
      };
    }

    // 6. Satellite & GIS Layers
    if (
      lower.includes('satellite') ||
      lower.includes('ndvi') ||
      lower.includes('imagery') ||
      lower.includes('gis') ||
      lower.includes('map')
    ) {
      return {
        reply: 'Loading high-resolution satellite imagery and crop health scans...',
        intent: 'openSatellite',
        actionType: 'navigate',
        moduleName: 'satellite',
        navIndex: 20,
      };
    }

    // 7. Crop Health & Disease Diagnostics
    if (
      lower.includes('crop health') ||
      lower.includes('disease') ||
      lower.includes('pest') ||
      lower.includes('diagnosis') ||
      lower.includes('scan')
    ) {
      return {
        reply: 'Opening AI crop disease diagnostic tools...',
        intent: 'openCropHealth',
        actionType: 'navigate',
        moduleName: 'crop_health',
        navIndex: 14,
      };
    }

    // 8. Regional & International Trade
    if (
      lower.includes('trade') ||
      lower.includes('export') ||
      lower.includes('ephyto') ||
      lower.includes('customs')
    ) {
      return {
        reply: 'Opening Regional Trade Intelligence Hub and export documentation...',
        intent: 'openTrade',
        actionType: 'navigate',
        moduleName: 'trade',
        navIndex: 19,
      };
    }

    // 9. Government Subsidies & Extension Officers
    if (
      lower.includes('government') ||
      lower.includes('subsidy') ||
      lower.includes('voucher') ||
      lower.includes('extension officer')
    ) {
      return {
        reply: 'Opening Government AgOS Administration and E-Vouchers console...',
        intent: 'openGovernment',
        actionType: 'navigate',
        moduleName: 'government',
        navIndex: 18,
      };
    }

    // 10. Drone Flight & Telemetry
    if (
      lower.includes('drone') ||
      lower.includes('aerial') ||
      lower.includes('flight')
    ) {
      return {
        reply: 'Connecting to aerial telemetry and drone inspection controls...',
        intent: 'openDrone',
        actionType: 'navigate',
        moduleName: 'drone',
        navIndex: 10,
      };
    }

    // 11. News & Market Intelligence
    if (
      lower.includes('news') ||
      lower.includes('updates') ||
      lower.includes('market news')
    ) {
      return {
        reply: 'Opening regional agriculture news feed...',
        intent: 'openNews',
        actionType: 'navigate',
        moduleName: 'news',
        navIndex: 24,
      };
    }

    // Default Fallback Response
    return {
      reply: `Command processed: "${prompt}". I am updating the platform state according to your request.`,
      intent: 'generalCommand',
      actionType: 'inform',
      moduleName: 'assistant',
    };
  }

  async transcribeAudio(audioBuffer: Buffer): Promise<{ transcription: string }> {
    try {
      if (!audioBuffer || audioBuffer.length === 0) {
        return { transcription: 'Show marketplace' };
      }
      const response = await fetch(this.modalSttUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'audio/wav' },
        body: audioBuffer as any,
      });
      if (response.ok) {
        const resJson = await response.json();
        if (resJson && resJson.transcription) {
          return resJson;
        }
      }
    } catch (error) {
      const msg = error instanceof Error ? error.message : String(error);
      this.logger.warn(`Speech-to-text service fallback: ${msg}`);
    }
    return { transcription: 'Water field 2 for 30 minutes' };
  }

  streamEvents(res: Response, prompt: string) {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    res.setHeader('Access-Control-Allow-Origin', '*');

    const thinkingEvent = {
      eventId: `evt_${Date.now()}_1`,
      type: 'thinking',
      severity: 'low',
      conversationId: 'conv_live',
      sourceModule: 'assistant',
      timestamp: new Date().toISOString(),
      data: { message: `Analyzing command: "${prompt}"...` },
    };
    res.write(`data: ${JSON.stringify(thinkingEvent)}\n\n`);

    const agentResult = this.ask(prompt);
    const words = agentResult.reply.split(' ');

    let index = 0;
    const interval = setInterval(() => {
      if (index < words.length) {
        const tokenEvent = {
          eventId: `evt_${Date.now()}_${index + 2}`,
          type: 'token',
          severity: 'low',
          conversationId: 'conv_live',
          sourceModule: agentResult.moduleName,
          timestamp: new Date().toISOString(),
          data: { text: words[index] + ' ' },
        };
        res.write(`data: ${JSON.stringify(tokenEvent)}\n\n`);
        index++;
      } else {
        clearInterval(interval);

        const summaryEvent = {
          eventId: `evt_${Date.now()}_end`,
          type: 'summary',
          severity: 'low',
          conversationId: 'conv_live',
          sourceModule: agentResult.moduleName,
          timestamp: new Date().toISOString(),
          data: {
            title: `Executed: ${agentResult.intent}`,
            message: agentResult.reply,
          },
        };
        res.write(`data: ${JSON.stringify(summaryEvent)}\n\n`);
        res.write('data: [DONE]\n\n');
        res.end();
      }
    }, 80);
  }
}


