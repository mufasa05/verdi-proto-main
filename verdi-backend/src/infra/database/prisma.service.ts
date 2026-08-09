import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    try {
      await this.$connect();
    } catch (e: any) {
      console.warn('Database connection unavailable, running server in decoupled API mode:', e?.message || e);
    }
  }

  async onModuleDestroy() {
    try {
      await this.$disconnect();
    } catch (_) {}
  }
}

