export type ToolCategory =
  | 'navigation'
  | 'marketplace_orders'
  | 'farm_operations'
  | 'logistics_finance'
  | 'data_analytics'
  | 'system';

export interface ToolParameter {
  type: string;
  description: string;
  enum?: string[];
  required?: boolean;
}

export interface ToolDefinition {
  name: string;
  category: ToolCategory;
  description: string;
  parameters: Record<string, ToolParameter>;
  allowedRoles?: string[];
}

export interface AgentExecutionRequest {
  prompt: string;
  userRole?: string;
  conversationId?: string;
  context?: Record<string, any>;
}

export interface ToolCallPayload {
  tool: string;
  category: ToolCategory;
  navIndex?: number;
  args: Record<string, any>;
  result: any;
}

export interface AgentExecutionResponse {
  reply: string;
  intent: string;
  actionType: 'navigate' | 'execute' | 'query' | 'inform';
  moduleName: string;
  navIndex?: number;
  toolCalls: ToolCallPayload[];
  speechFeedback: string;
}
