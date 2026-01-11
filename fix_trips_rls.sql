-- ================================================================================
-- FIX RLS POLICIES FOR TRIPS TABLE
-- ================================================================================
-- This script fixes the Row Level Security policies to allow trip creation
-- Run this in your Supabase SQL Editor
-- ================================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Anyone can view trips" ON trips;
DROP POLICY IF EXISTS "Only authenticated users can insert trips" ON trips;
DROP POLICY IF EXISTS "Authenticated users can insert trips" ON trips;
DROP POLICY IF EXISTS "Only authenticated users can update trips" ON trips;
DROP POLICY IF EXISTS "Authenticated users can update trips" ON trips;
DROP POLICY IF EXISTS "Only authenticated users can delete trips" ON trips;
DROP POLICY IF EXISTS "Authenticated users can delete trips" ON trips;

-- RLS Policy: Anyone can view trips (public access)
CREATE POLICY "Anyone can view trips"
  ON trips FOR SELECT
  USING (true);

-- RLS Policy: Authenticated users can insert trips
CREATE POLICY "Authenticated users can insert trips"
  ON trips FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- RLS Policy: Authenticated users can update trips
CREATE POLICY "Authenticated users can update trips"
  ON trips FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- RLS Policy: Authenticated users can delete trips
CREATE POLICY "Authenticated users can delete trips"
  ON trips FOR DELETE
  TO authenticated
  USING (true);

-- Verify policies were created
SELECT schemaname, tablename, policyname, roles
FROM pg_policies 
WHERE tablename = 'trips';
