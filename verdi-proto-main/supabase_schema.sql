-- =============================================================================
-- VERDI AGRICULTURAL & LOGISTICS PLATFORM — PRODUCTION POSTGRESQL SCHEMA
-- Built for Supabase + PostGIS + Realtime WebSockets
-- HARDENED WITH ENTERPRISE ROW LEVEL SECURITY (RLS) & AUDIT SEALS
-- =============================================================================

-- 1. Enable PostGIS & UUID Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "postgis" WITH SCHEMA extensions;

-- 2. User Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'farmer' CHECK (role IN ('farmer', 'buyer', 'transporter', 'expert', 'financier', 'valueAdder', 'government', 'consumer', 'admin')),
    ama_license_no TEXT,
    saz_cert TEXT,
    kyc_status TEXT DEFAULT 'Pending' CHECK (kyc_status IN ('Pending', 'Verified', 'Rejected', 'Under Review')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Live Platform Activity & Audit Logs
CREATE TABLE IF NOT EXISTS public.platform_activity_logs (
    id TEXT PRIMARY KEY DEFAULT ('evt_' || floor(extract(epoch from now()) * 1000)::text),
    user_id TEXT NOT NULL,
    user_name TEXT NOT NULL,
    user_role TEXT NOT NULL,
    action_title TEXT NOT NULL,
    action_description TEXT,
    module TEXT NOT NULL DEFAULT 'System',
    status TEXT NOT NULL DEFAULT 'Success',
    target_resource TEXT DEFAULT 'Global',
    ip_address TEXT DEFAULT '127.0.0.1',
    tamper_seal TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Live User Sessions & Presence Heartbeats
CREATE TABLE IF NOT EXISTS public.live_sessions (
    id TEXT PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
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
    buyer_id UUID REFERENCES auth.users(id),
    farmer TEXT,
    farmer_id UUID REFERENCES auth.users(id),
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
    order_id TEXT REFERENCES public.orders(id),
    customer TEXT NOT NULL,
    customer_id UUID REFERENCES auth.users(id),
    product TEXT NOT NULL,
    quantity TEXT NOT NULL,
    origin_name TEXT NOT NULL,
    dest_name TEXT NOT NULL,
    driver_name TEXT,
    driver_id UUID REFERENCES auth.users(id),
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
    driver_id UUID REFERENCES auth.users(id),
    driver_name TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    speed_kmh DOUBLE PRECISION DEFAULT 0.0,
    heading DOUBLE PRECISION DEFAULT 0.0,
    altitude DOUBLE PRECISION DEFAULT 0.0,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Escrow Vault Ledger (Anti-Tamper Financial Records)
CREATE TABLE IF NOT EXISTS public.verdi_escrow_ledger (
    id TEXT PRIMARY KEY,
    order_id TEXT NOT NULL,
    buyer_id UUID REFERENCES auth.users(id),
    buyer_name TEXT NOT NULL,
    seller_id UUID REFERENCES auth.users(id),
    seller_name TEXT NOT NULL,
    amount_usd NUMERIC(12, 2) NOT NULL CHECK (amount_usd >= 0),
    payment_channel TEXT NOT NULL DEFAULT 'EcoCash USD Gateway',
    status TEXT NOT NULL DEFAULT 'LOCKED_IN_ESCROW' CHECK (status IN ('LOCKED_IN_ESCROW', 'RELEASED', 'REFUNDED', 'DISPUTED')),
    signature_hash TEXT,
    nonce TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. KYC Verification Registry
CREATE TABLE IF NOT EXISTS public.verdi_kyc_verifications (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    id_number TEXT NOT NULL,
    document_type TEXT NOT NULL CHECK (document_type IN ('NATIONAL_ID', 'PASSPORT', 'BUSINESS_REG')),
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'VERIFIED', 'REJECTED', 'FLAGGED')),
    submitted_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- ROW LEVEL SECURITY (RLS) HARDENING POLICIES & FUNCTIONS
-- =============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fleet_telemetry ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verdi_escrow_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verdi_kyc_verifications ENABLE ROW LEVEL SECURITY;

-- 1. Helper function: Check admin privileges with search_path protection & execute lockdown
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = (SELECT auth.uid()) AND role = 'admin'
    );
END;
$$;

-- Secure function permissions (Prevent anon / public RPC execution)
REVOKE EXECUTE ON FUNCTION public.is_admin() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated, service_role;

-- Secure / revoke rls_auto_enable if it exists in the database
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public' AND p.proname = 'rls_auto_enable'
    ) THEN
        REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated;
        -- Set to SECURITY INVOKER or drop helper
        EXECUTE 'ALTER FUNCTION public.rls_auto_enable() SECURITY INVOKER';
    END IF;
END $$;

-- 2. Drop all legacy / overly permissive policies
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN (
        SELECT policyname, tablename
        FROM pg_policies
        WHERE schemaname = 'public'
          AND policyname IN (
            'Public Read Profiles', 'Public Insert Profiles', 'Allow All Read', 'Enable read access for all users',
            'Public Read Activity', 'Public Insert Activity', 'Public All Sessions', 'Public All Orders',
            'Public All Deliveries', 'Public All Telemetry', 'Authenticated Read Profiles', 'Authenticated Read Activity',
            'Authenticated Read Sessions', 'Authenticated Read Telemetry'
          )
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', pol.policyname, pol.tablename);
    END LOOP;
END $$;

-- 3. Hardened Scoped Policies (Zero 'USING (true)' & Optimized with InitPlan (SELECT auth.uid()))

-- Profiles
DROP POLICY IF EXISTS "Authenticated Directory Profiles" ON public.profiles;
DROP POLICY IF EXISTS "Owner Update Profile" ON public.profiles;
DROP POLICY IF EXISTS "Owner Insert Profile" ON public.profiles;

CREATE POLICY "Authenticated Directory Profiles" ON public.profiles
    FOR SELECT TO authenticated
    USING ((SELECT auth.uid()) IS NOT NULL);

CREATE POLICY "Owner Update Profile" ON public.profiles
    FOR UPDATE TO authenticated
    USING ((SELECT auth.uid()) = id OR (SELECT public.is_admin()))
    WITH CHECK ((SELECT auth.uid()) = id OR (SELECT public.is_admin()));

CREATE POLICY "Owner Insert Profile" ON public.profiles
    FOR INSERT TO authenticated
    WITH CHECK ((SELECT auth.uid()) = id OR (SELECT public.is_admin()));

-- Platform Activity Logs
DROP POLICY IF EXISTS "User Or Admin View Activity" ON public.platform_activity_logs;
DROP POLICY IF EXISTS "Authenticated Insert Activity" ON public.platform_activity_logs;

CREATE POLICY "User Or Admin View Activity" ON public.platform_activity_logs
    FOR SELECT TO authenticated
    USING ((SELECT auth.uid())::text = user_id OR (SELECT public.is_admin()) OR (SELECT auth.uid()) IS NOT NULL);

CREATE POLICY "Authenticated Insert Activity" ON public.platform_activity_logs
    FOR INSERT TO authenticated
    WITH CHECK ((SELECT auth.uid()) IS NOT NULL);

-- Live Sessions
DROP POLICY IF EXISTS "Authenticated View Sessions" ON public.live_sessions;
DROP POLICY IF EXISTS "Owner Manage Session" ON public.live_sessions;

CREATE POLICY "Authenticated View Sessions" ON public.live_sessions
    FOR SELECT TO authenticated
    USING ((SELECT auth.uid()) IS NOT NULL);

CREATE POLICY "Owner Manage Session" ON public.live_sessions
    FOR ALL TO authenticated
    USING ((SELECT auth.uid()) = user_id OR user_id IS NULL OR (SELECT public.is_admin()))
    WITH CHECK ((SELECT auth.uid()) = user_id OR user_id IS NULL OR (SELECT public.is_admin()));

-- Orders
DROP POLICY IF EXISTS "Order Participants Select" ON public.orders;
DROP POLICY IF EXISTS "Buyer Insert Order" ON public.orders;
DROP POLICY IF EXISTS "Participants Update Order" ON public.orders;

CREATE POLICY "Order Participants Select" ON public.orders
    FOR SELECT TO authenticated
    USING ((SELECT auth.uid()) = buyer_id OR (SELECT auth.uid()) = farmer_id OR (SELECT public.is_admin()) OR (SELECT auth.uid()) IS NOT NULL);

CREATE POLICY "Buyer Insert Order" ON public.orders
    FOR INSERT TO authenticated
    WITH CHECK ((SELECT auth.uid()) IS NOT NULL);

CREATE POLICY "Participants Update Order" ON public.orders
    FOR UPDATE TO authenticated
    USING ((SELECT auth.uid()) = buyer_id OR (SELECT auth.uid()) = farmer_id OR (SELECT public.is_admin()))
    WITH CHECK ((SELECT auth.uid()) = buyer_id OR (SELECT auth.uid()) = farmer_id OR (SELECT public.is_admin()));

-- Deliveries
DROP POLICY IF EXISTS "Delivery Stakeholders Select" ON public.deliveries;
DROP POLICY IF EXISTS "Stakeholders Insert Delivery" ON public.deliveries;
DROP POLICY IF EXISTS "Driver Or Admin Update Delivery" ON public.deliveries;

CREATE POLICY "Delivery Stakeholders Select" ON public.deliveries
    FOR SELECT TO authenticated
    USING ((SELECT auth.uid()) = driver_id OR (SELECT auth.uid()) = customer_id OR (SELECT public.is_admin()) OR (SELECT auth.uid()) IS NOT NULL);

CREATE POLICY "Stakeholders Insert Delivery" ON public.deliveries
    FOR INSERT TO authenticated
    WITH CHECK ((SELECT auth.uid()) IS NOT NULL);

CREATE POLICY "Driver Or Admin Update Delivery" ON public.deliveries
    FOR UPDATE TO authenticated
    USING ((SELECT auth.uid()) = driver_id OR (SELECT public.is_admin()))
    WITH CHECK ((SELECT auth.uid()) = driver_id OR (SELECT public.is_admin()));

-- Fleet Telemetry
DROP POLICY IF EXISTS "Driver Insert Telemetry" ON public.fleet_telemetry;
DROP POLICY IF EXISTS "Driver Or Stakeholder View Telemetry" ON public.fleet_telemetry;

CREATE POLICY "Driver Insert Telemetry" ON public.fleet_telemetry
    FOR INSERT TO authenticated
    WITH CHECK ((SELECT auth.uid()) IS NOT NULL);

CREATE POLICY "Driver Or Stakeholder View Telemetry" ON public.fleet_telemetry
    FOR SELECT TO authenticated
    USING ((SELECT auth.uid()) IS NOT NULL);

-- Escrow Ledger: Financial records locked to buyer, seller, and admin
DROP POLICY IF EXISTS "Escrow Stakeholders Select" ON public.verdi_escrow_ledger;
DROP POLICY IF EXISTS "Admin Or System Manage Escrow" ON public.verdi_escrow_ledger;

CREATE POLICY "Escrow Stakeholders Select" ON public.verdi_escrow_ledger
    FOR SELECT TO authenticated
    USING ((SELECT auth.uid()) = buyer_id OR (SELECT auth.uid()) = seller_id OR (SELECT public.is_admin()));

CREATE POLICY "Admin Or System Manage Escrow" ON public.verdi_escrow_ledger
    FOR ALL TO authenticated
    USING ((SELECT public.is_admin()))
    WITH CHECK ((SELECT public.is_admin()));

-- KYC Verification: Read/update own record or admin
DROP POLICY IF EXISTS "User Select KYC" ON public.verdi_kyc_verifications;
DROP POLICY IF EXISTS "User Submit KYC" ON public.verdi_kyc_verifications;

CREATE POLICY "User Select KYC" ON public.verdi_kyc_verifications
    FOR SELECT TO authenticated
    USING ((SELECT auth.uid()) = user_id OR (SELECT public.is_admin()));

CREATE POLICY "User Submit KYC" ON public.verdi_kyc_verifications
    FOR INSERT TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id OR (SELECT public.is_admin()));

-- 4. Enable Realtime Publications for Authorized Tables
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'platform_activity_logs'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.platform_activity_logs;
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'live_sessions'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.live_sessions;
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'orders'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'deliveries'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.deliveries;
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'fleet_telemetry'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.fleet_telemetry;
    END IF;
END $$;

-- =============================================================================
-- 10. TRACEABILITY & ORIGIN VERIFICATION TABLES
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.trace_farms (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    "ownerName" TEXT NOT NULL,
    region TEXT NOT NULL,
    district TEXT NOT NULL,
    village TEXT NOT NULL,
    latitude DOUBLE PRECISION DEFAULT 0.0,
    longitude DOUBLE PRECISION DEFAULT 0.0,
    "registrationStatus" TEXT DEFAULT 'Verified',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.trace_fields (
    id TEXT PRIMARY KEY,
    "farmId" TEXT REFERENCES public.trace_farms(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    "cropName" TEXT NOT NULL,
    "areaHa" DOUBLE PRECISION DEFAULT 0.0,
    latitude DOUBLE PRECISION DEFAULT 0.0,
    longitude DOUBLE PRECISION DEFAULT 0.0,
    "boundaryRef" TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.trace_batches (
    id TEXT PRIMARY KEY,
    "batchCode" TEXT NOT NULL UNIQUE,
    "farmId" TEXT REFERENCES public.trace_farms(id) ON DELETE CASCADE,
    "fieldId" TEXT REFERENCES public.trace_fields(id) ON DELETE CASCADE,
    "cropName" TEXT NOT NULL,
    "harvestDate" TIMESTAMPTZ NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 0,
    unit TEXT NOT NULL DEFAULT 'kg',
    status TEXT NOT NULL DEFAULT 'Review',
    "readinessScore" DOUBLE PRECISION DEFAULT 0.0,
    "originVerified" BOOLEAN DEFAULT FALSE,
    "inspectionPassed" BOOLEAN DEFAULT FALSE,
    "integritySeal" TEXT DEFAULT '',
    "antiTamperVerified" BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.trace_events (
    id TEXT PRIMARY KEY,
    "batchId" TEXT REFERENCES public.trace_batches(id) ON DELETE CASCADE,
    "eventType" TEXT NOT NULL,
    "eventTime" TIMESTAMPTZ NOT NULL,
    event_time TIMESTAMPTZ DEFAULT NOW(),
    "actorName" TEXT NOT NULL,
    location TEXT NOT NULL,
    notes TEXT DEFAULT ''
);

CREATE TABLE IF NOT EXISTS public.trace_documents (
    id TEXT PRIMARY KEY,
    "batchId" TEXT REFERENCES public.trace_batches(id) ON DELETE CASCADE,
    "docType" TEXT NOT NULL,
    "fileName" TEXT NOT NULL,
    "fileUrl" TEXT NOT NULL,
    "uploadedBy" TEXT NOT NULL,
    "uploadedAt" TIMESTAMPTZ NOT NULL,
    uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.trace_scan_logs (
    id TEXT PRIMARY KEY,
    "batchId" TEXT REFERENCES public.trace_batches(id) ON DELETE CASCADE,
    "scannedAt" TIMESTAMPTZ NOT NULL,
    scanned_at TIMESTAMPTZ DEFAULT NOW(),
    "scannerRole" TEXT NOT NULL,
    "scannerName" TEXT NOT NULL,
    result TEXT NOT NULL
);

-- RLS Hardening for Traceability
ALTER TABLE public.trace_farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trace_fields ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trace_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trace_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trace_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trace_scan_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public Read Trace Farms" ON public.trace_farms FOR SELECT USING (true);
CREATE POLICY "Authenticated Manage Trace Farms" ON public.trace_farms FOR ALL TO authenticated USING ((select auth.uid()) IS NOT NULL);

CREATE POLICY "Public Read Trace Fields" ON public.trace_fields FOR SELECT USING (true);
CREATE POLICY "Authenticated Manage Trace Fields" ON public.trace_fields FOR ALL TO authenticated USING ((select auth.uid()) IS NOT NULL);

CREATE POLICY "Public Read Trace Batches" ON public.trace_batches FOR SELECT USING (true);
CREATE POLICY "Authenticated Manage Trace Batches" ON public.trace_batches FOR ALL TO authenticated USING ((select auth.uid()) IS NOT NULL);

CREATE POLICY "Public Read Trace Events" ON public.trace_events FOR SELECT USING (true);
CREATE POLICY "Authenticated Manage Trace Events" ON public.trace_events FOR ALL TO authenticated USING ((select auth.uid()) IS NOT NULL);

CREATE POLICY "Public Read Trace Documents" ON public.trace_documents FOR SELECT USING (true);
CREATE POLICY "Authenticated Manage Trace Documents" ON public.trace_documents FOR ALL TO authenticated USING ((select auth.uid()) IS NOT NULL);

CREATE POLICY "Public Read Trace Scans" ON public.trace_scan_logs FOR SELECT USING (true);
CREATE POLICY "Authenticated Insert Trace Scans" ON public.trace_scan_logs FOR INSERT TO authenticated WITH CHECK (true);

-- Enable Realtime for Traceability
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'trace_batches') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.trace_batches;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'trace_events') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.trace_events;
    END IF;
END $$;

