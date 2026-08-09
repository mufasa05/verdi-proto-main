import { Body, Controller, Get, Post, Query, Req, Res } from '@nestjs/common';
import { Response } from 'express';
import { AssistantService } from './assistant.service';
import { AutonomousAgentService } from './services/autonomous.agent.service';
import { AgentExecutionRequest } from './types/agent.types';

@Controller('assistant')
export class AssistantController {
  constructor(
    private readonly assistantService: AssistantService,
    private readonly autonomousAgentService: AutonomousAgentService,
  ) {}

  @Post('ask')
  ask(@Body('text') text: string) {
    return this.assistantService.ask(text);
  }

  @Post('agent/execute')
  executeAgent(@Body() body: AgentExecutionRequest) {
    return this.autonomousAgentService.execute(body);
  }

  @Post('agent/stream')
  streamAgentPost(@Body() body: AgentExecutionRequest, @Res() res: Response) {
    return this.autonomousAgentService.streamEvents(res, body);
  }

  @Get('agent/stream')
  streamAgentGet(@Query('prompt') prompt: string, @Query('userRole') userRole: string, @Res() res: Response) {
    return this.autonomousAgentService.streamEvents(res, { prompt, userRole });
  }

  @Post('stt')
  async transcribeStt(@Req() req: any, @Body() body: any) {
    return this._extractAndTranscribe(req, body);
  }

  @Post('transcribe')
  async transcribe(@Req() req: any, @Body() body: any) {
    return this._extractAndTranscribe(req, body);
  }

  @Post('stream')
  streamPost(@Body('prompt') prompt: string, @Res() res: Response) {
    return this.assistantService.streamEvents(res, prompt || 'System Status Overview');
  }

  @Get('stream')
  streamGet(@Query('prompt') prompt: string, @Res() res: Response) {
    return this.assistantService.streamEvents(res, prompt || 'System Status Overview');
  }

  private async _extractAndTranscribe(req: any, body: any) {
    let buffer: Buffer;
    if (Buffer.isBuffer(body)) {
      buffer = body;
    } else if (body && body.audio) {
      buffer = Buffer.from(body.audio, 'base64');
    } else if (req && req.body && Buffer.isBuffer(req.body)) {
      buffer = req.body;
    } else {
      buffer = Buffer.from('');
    }
    return this.assistantService.transcribeAudio(buffer);
  }
}

@Controller('v1/assistant')
export class V1AssistantController extends AssistantController {}



