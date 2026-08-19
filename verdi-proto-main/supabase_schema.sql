-- =============================================================================
-- VERDI AGRICULTURAL & LOGISTICS PLATFORM — PRODUCTION POSTGRESQL SCHEMA
-- Built for Supabase + PostGIS + Realtime WebSockets
-- =============================================================================

-- 1. Enable PostGIS for Parcel Polygons & Fleet GPS Route Analysis
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- 2. User Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'farmer' CHECK (role IN ('farmer', 'buyer', 'transporter', 'expert', 'financier', 'valueAdder', 'government', 'consumer', 'admin')),
    ama_license_no TEXT,
    saz_cert TEXT,
    kyc_status TEXT DEFAULT 'Verified',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Live Platform Activity & Audit Logs (Real-time Broadcast)
CREATE TABLE IF NOT EXISTS public.platform_activity_logs (
    id TEXT PRIMARY KEY DEFAULT ('evt_' || floor(extract(epoch from now()) * 1000)::text),
    user_name TEXT NOT NULL,
    user_role TEXT NOT NULL,
    action_title TEXT NOT NULL,
    action_description TEXT,
    module TEXT NOT NULL DEFAULT 'System',
    status TEXT NOT NULL DEFAULT 'Success',
    target_resource TEXT DEFAULT 'Global',
    ip_address TEXT DEFAULT '192.168.1.1',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Live User Sessions & Presence Heartbeats
CREATE TABLE IF NOT EXISTS public.live_sessions (
    id TEXT PRIMARY KEY,
    user_name TEXT NOT NULL,
    user_role TEXT NOT NULL,
    region TEXT DEFAULT 'Harare Metropolitan',
    is_online BOOLEAN DEFAULT TRUE,
    last_heartbeat TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Marketplace Orders & Escrow Smart Contracts
CREATE TABLE IF NOT EXISTS public.orders (
    id TEXT PRIMARY KEY,
    buyer TEXT NOT NULL,
    farmer TEXT,
    items TEXT NOT NULL,
    total TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processing', 'Delivered', 'Cancelled', 'In Transit')),
    payment TEXT NOT NULL DEFAULT 'Escrow Secured' CHECK (payment IN ('Paid', 'Unpaid', 'Pending', 'Escrow Secured')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    delivery_date TIMESTAMPTZ,
    location TEXT,
    contact_phone TEXT,
    payment_method TEXT DEFAULT 'EcoCash Escrow'
);

-- 6. Logistics Dispatches & Reefer Telemetry
CREATE TABLE IF NOT EXISTS public.deliveries (
    id TEXT PRIMARY KEY,
    customer TEXT NOT NULL,
    product TEXT NOT NULL,
    quantity TEXT NOT NULL,
    origin_name TEXT NOT NULL,
    dest_name TEXT NOT NULL,
    driver_name TEXT,
    vehicle_model TEXT,
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Picked up', 'On the way', 'Delivered')),
    temperature TEXT DEFAULT '+4.0°C',
    humidity TEXT DEFAULT '88%',
    distance_remaining TEXT DEFAULT '0 km',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Real-Time Fleet GPS Ping Stream
CREATE TABLE IF NOT EXISTS public.fleet_telemetry (
    id BIGSERIAL PRIMARY KEY,
    vehicle_id TEXT NOT NULL,
    driver_name TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    speed_kmh DOUBLE PRECISION DEFAULT 0.0,
    heading DOUBLE PRECISION DEFAULT 0.0,
    altitude DOUBLE PRECISION DEFAULT 0.0,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Row Level Security (RLS) Policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fleet_telemetry ENABLE ROW LEVEL SECURITY;

-- Allow read access for authenticated & anon clients
CREATE POLICY "Public Read Profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Public Insert Profiles" ON public.profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "Public Read Activity" ON public.platform_activity_logs FOR SELECT USING (true);
CREATE POLICY "Public Insert Activity" ON public.platform_activity_logs FOR INSERT WITH CHECK (true);
CREATE POLICY "Public All Sessions" ON public.live_sessions FOR ALL USING (true);
CREATE POLICY "Public All Orders" ON public.orders FOR ALL USING (true);
CREATE POLICY "Public All Deliveries" ON public.deliveries FOR ALL USING (true);
CREATE POLICY "Public All Telemetry" ON public.fleet_telemetry FOR ALL USING (true);

-- 9. Enable Realtime Publications for Live Sync
ALTER PUBLICATION supabase_realtime ADD TABLE public.platform_activity_logs;
ALTER PUBLICATION supabase_realtime ADD TABLE public.live_sessions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
ALTER PUBLICATION supabase_realtime ADD TABLE public.deliveries;
ALTER PUBLICATION supabase_realtime ADD TABLE public.fleet_telemetry;
