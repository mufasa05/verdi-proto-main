import { Module } from '@nestjs/common';
import { AssistantController, V1AssistantController } from './assistant.controller';
import { AssistantService } from './assistant.service';
import { AgentToolsRegistry } from './services/agent.tools.registry';
import { AutonomousAgentService } from './services/autonomous.agent.service';

@Module({
  controllers: [AssistantController, V1AssistantController],
  providers: [AssistantService, AgentToolsRegistry, AutonomousAgentService],
  exports: [AssistantService, AgentToolsRegistry, AutonomousAgentService],
})
export class AssistantModule {}
