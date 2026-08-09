import { Injectable, Logger } from '@nestjs/common';
import { ToolDefinition, ToolCallPayload } from '../types/agent.types';

@Injectable()
export class AgentToolsRegistry {
  private readonly logger = new Logger(AgentToolsRegistry.name);

  public static readonly MODULE_MAP: Record<string, number> = {
    home: 0,
    marketplace: 1,
    assistant: 2,
    analytics: 3,
    orders: 4,
    logistics: 5,
    payments: 6,
    notifications: 7,
    government_irrigation: 8,
    farmer_irrigation: 9,
    drone: 10,
    farm_operations: 11,
    dashboard: 12,
    geospatial: 13,
    crop_health: 14,
    traceability: 15,
    finance: 16,
    weather: 17,
    government: 18,
    trade: 19,
    satellite: 20,
    settings: 21,
    export: 22,
    admin: 23,
    news: 24,
  };

  private readonly tools: Record<string, ToolDefinition> = {
    // ── 1. Navigation Tools ──────────────────────────────────────────────────
    navigate_to_page: {
      name: 'navigate_to_page',
      category: 'navigation',
      description: 'Navigate hands-free to any of the 25 Verdi platform modules.',
      parameters: {
        page_index: { type: 'number', description: 'Module index (0-24)' },
        page_name: { type: 'string', description: 'Name of module (e.g. marketplace, drone, satellite)' },
      },
    },

    // ── 2. Marketplace + Orders Tools ────────────────────────────────────────
    search_product: {
      name: 'search_product',
      category: 'marketplace_orders',
      description: 'Search agricultural marketplace for produce, fertilizers, seeds, or equipment.',
      parameters: {
        query: { type: 'string', description: 'Product search term' },
        category: { type: 'string', description: 'Category filter e.g. fertilizer, seed, solar' },
      },
    },
    add_to_cart: {
      name: 'add_to_cart',
      category: 'marketplace_orders',
      description: 'Add a specified agricultural product to the user shopping cart.',
      parameters: {
        product_id: { type: 'string', description: 'Product name or ID' },
        quantity: { type: 'number', description: 'Quantity count' },
        unit: { type: 'string', description: 'Unit e.g. bags, kg, units, tons' },
      },
      allowedRoles: ['farmer', 'buyer', 'consumer', 'valueAdder', 'admin'],
    },
    view_cart: {
      name: 'view_cart',
      category: 'marketplace_orders',
      description: 'Open marketplace cart drawer and display cart items.',
      parameters: {},
    },
    place_order: {
      name: 'place_order',
      category: 'marketplace_orders',
      description: 'Place purchase order for items currently in cart.',
      parameters: {
        payment_method: { type: 'string', description: 'Payment method: EcoCash, Escrow, Wallet, Bank' },
      },
      allowedRoles: ['buyer', 'consumer', 'valueAdder', 'admin'],
    },
    track_order: {
      name: 'track_order',
      category: 'marketplace_orders',
      description: 'Track real-time status of a purchase order.',
      parameters: {
        order_id: { type: 'string', description: 'Order ID string' },
      },
    },

    // ── 3. Farm Operations Tools ─────────────────────────────────────────────
    start_irrigation: {
      name: 'start_irrigation',
      category: 'farm_operations',
      description: 'Activate smart irrigation pump protocol for a target field zone.',
      parameters: {
        zone: { type: 'string', description: 'Field zone e.g. Field A Maize, Zone 2' },
        duration_minutes: { type: 'number', description: 'Irrigation duration in minutes' },
      },
      allowedRoles: ['farmer', 'expert', 'government', 'admin'],
    },
    stop_irrigation: {
      name: 'stop_irrigation',
      category: 'farm_operations',
      description: 'Stop active irrigation pump for a specified zone.',
      parameters: {
        zone: { type: 'string', description: 'Target field zone' },
      },
      allowedRoles: ['farmer', 'expert', 'government', 'admin'],
    },
    get_soil_moisture: {
      name: 'get_soil_moisture',
      category: 'farm_operations',
      description: 'Retrieve real-time IoT soil moisture sensor readings.',
      parameters: {
        zone: { type: 'string', description: 'Target field zone' },
      },
    },
    start_drone_flight: {
      name: 'start_drone_flight',
      category: 'farm_operations',
      description: 'Launch autonomous drone inspection flight mission over field.',
      parameters: {
        field_id: { type: 'string', description: 'Field block e.g. Block B, Zone 1' },
        mission_type: { type: 'string', description: 'Mission type: inspection, moisture, pest_scan' },
      },
      allowedRoles: ['farmer', 'expert', 'admin'],
    },
    get_drone_telemetry: {
      name: 'get_drone_telemetry',
      category: 'farm_operations',
      description: 'Fetch current drone aerial telemetry status and battery level.',
      parameters: {},
    },
    scan_crop_disease: {
      name: 'scan_crop_disease',
      category: 'farm_operations',
      description: 'Open AI crop health disease diagnostic scanner.',
      parameters: {
        crop_type: { type: 'string', description: 'Target crop e.g. tomato, maize, tea' },
      },
    },
    get_ndvi_map: {
      name: 'get_ndvi_map',
      category: 'farm_operations',
      description: 'Load high-resolution satellite imagery and NDVI spectral health layer.',
      parameters: {
        field_id: { type: 'string', description: 'Field block ID' },
      },
    },

    // ── 4. Logistics + Finance Tools ─────────────────────────────────────────
    request_logistics: {
      name: 'request_logistics',
      category: 'logistics_finance',
      description: 'Request commercial truck or transport vehicle for crop dispatch.',
      parameters: {
        pickup_location: { type: 'string', description: 'Origin location' },
        destination: { type: 'string', description: 'Destination market or warehouse' },
        cargo: { type: 'string', description: 'Crop cargo description and weight' },
      },
    },
    make_payment: {
      name: 'make_payment',
      category: 'logistics_finance',
      description: 'Process escrow or wallet payment for logistics or produce.',
      parameters: {
        amount: { type: 'number', description: 'Payment amount in USD' },
        method: { type: 'string', description: 'EcoCash, Bank, Escrow, AgriWallet' },
      },
    },
    check_wallet_balance: {
      name: 'check_wallet_balance',
      category: 'logistics_finance',
      description: 'Check available AgriWallet balance and credit rating.',
      parameters: {},
    },
    generate_ephyto_certificate: {
      name: 'generate_ephyto_certificate',
      category: 'logistics_finance',
      description: 'Generate electronic phytosanitary customs export documentation.',
      parameters: {
        batch_id: { type: 'string', description: 'Crop batch ID' },
      },
      allowedRoles: ['farmer', 'buyer', 'valueAdder', 'government', 'admin'],
    },

    // ── 5. Data + Analytics Tools ────────────────────────────────────────────
    get_yield_forecast: {
      name: 'get_yield_forecast',
      category: 'data_analytics',
      description: 'Calculate AI crop yield forecast and revenue projection.',
      parameters: {
        crop: { type: 'string', description: 'Crop type e.g. maize, wheat, soybeans' },
        season: { type: 'string', description: 'Season e.g. 2026/2027' },
      },
    },
    get_weather_forecast: {
      name: 'get_weather_forecast',
      category: 'data_analytics',
      description: 'Get atmospheric weather radar and precipitation forecast.',
      parameters: {
        days: { type: 'number', description: 'Forecast days (1-7)' },
      },
    },
    get_market_prices: {
      name: 'get_market_prices',
      category: 'data_analytics',
      description: 'Fetch regional agricultural commodity market price index.',
      parameters: {
        commodity: { type: 'string', description: 'Commodity e.g. maize, tomatoes, tea' },
        region: { type: 'string', description: 'Region e.g. Harare, Lusaka, Johannesburg' },
      },
    },
    show_dashboard_kpi: {
      name: 'show_dashboard_kpi',
      category: 'data_analytics',
      description: 'Display farm operations key performance indicator overview.',
      parameters: {
        kpi_name: { type: 'string', description: 'KPI e.g. yield, revenue, water_usage' },
      },
    },

    // ── 6. System Tools ──────────────────────────────────────────────────────
    show_notifications: {
      name: 'show_notifications',
      category: 'system',
      description: 'View real-time platform system notifications and weather alerts.',
      parameters: {
        filter: { type: 'string', description: 'Filter: all, critical, warning, info' },
      },
    },
    change_user_role: {
      name: 'change_user_role',
      category: 'system',
      description: 'Switch active user stakeholder role on Verdi platform.',
      parameters: {
        role: { type: 'string', description: 'Role: farmer, buyer, driver, transporter, valueAdder, expert, financier, government, consumer, admin' },
      },
    },
    get_system_status: {
      name: 'get_system_status',
      category: 'system',
      description: 'Retrieve real-time backend API, Redis outbox, and IoT gateway health status.',
      parameters: {},
    },
  };

  getAllTools(): ToolDefinition[] {
    return Object.values(this.tools);
  }

  getTool(name: string): ToolDefinition | undefined {
    return this.tools[name];
  }

  isRoleAllowed(toolName: string, role?: string): boolean {
    const tool = this.tools[toolName];
    if (!tool || !tool.allowedRoles || tool.allowedRoles.length === 0) {
      return true;
    }
    if (!role) return true;
    const normRole = role.toLowerCase();
    return tool.allowedRoles.map((r) => r.toLowerCase()).includes(normRole);
  }

  executeToolCall(toolName: string, args: Record<string, any>, userRole?: string): ToolCallPayload {
    const tool = this.tools[toolName];
    if (!tool) {
      return {
        tool: toolName,
        category: 'system',
        args,
        result: { success: false, error: `Tool ${toolName} not found` },
      };
    }

    if (!this.isRoleAllowed(toolName, userRole)) {
      return {
        tool: toolName,
        category: tool.category,
        args,
        result: {
          success: false,
          error: `Permission denied: Role '${userRole || 'guest'}' is not authorized to call '${toolName}'.`,
        },
      };
    }

    let navIndex: number | undefined;
    const normTool = toolName.toLowerCase();

    if (normTool === 'navigate_to_page') {
      const idx = typeof args.page_index === 'number' ? args.page_index : AgentToolsRegistry.MODULE_MAP[String(args.page_name).toLowerCase()];
      navIndex = typeof idx === 'number' ? idx : 0;
    } else if (normTool.includes('cart') || normTool.includes('product')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.marketplace;
    } else if (normTool.includes('order')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.orders;
    } else if (normTool.includes('irrigation') || normTool.includes('moisture')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.farmer_irrigation;
    } else if (normTool.includes('drone')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.drone;
    } else if (normTool.includes('disease') || normTool.includes('crop_health')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.crop_health;
    } else if (normTool.includes('ndvi') || normTool.includes('satellite')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.satellite;
    } else if (normTool.includes('logistics') || normTool.includes('truck')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.logistics;
    } else if (normTool.includes('payment') || normTool.includes('wallet') || normTool.includes('finance')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.finance;
    } else if (normTool.includes('ephyto') || normTool.includes('export')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.export;
    } else if (normTool.includes('yield') || normTool.includes('analytics')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.analytics;
    } else if (normTool.includes('weather') || normTool.includes('forecast')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.weather;
    } else if (normTool.includes('prices') || normTool.includes('trade')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.trade;
    } else if (normTool.includes('kpi') || normTool.includes('dashboard')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.dashboard;
    } else if (normTool.includes('notification')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.notifications;
    } else if (normTool.includes('system') || normTool.includes('admin')) {
      navIndex = AgentToolsRegistry.MODULE_MAP.admin;
    }

    return {
      tool: toolName,
      category: tool.category,
      navIndex,
      args,
      result: {
        success: true,
        executedAt: new Date().toISOString(),
        message: `Executed tool '${toolName}' successfully.`,
      },
    };
  }
}
