import { Injectable, Logger } from '@nestjs/common';

export type PlatformEvent = {
  id: string;
  type: string;
  tenantId?: string;
  sourceModule: string;
  actorId?: string;
  severity?: 'low' | 'medium' | 'high' | 'critical';
  timestamp: string;
  traceId?: string;
  payload: Record<string, unknown>;
};

@Injectable()
export class EventBusService {
  private readonly logger = new Logger(EventBusService.name);

  async publish(event: PlatformEvent) {
    this.logger.log(`Event published: ${event.type}`);
    return event;
  }
}
