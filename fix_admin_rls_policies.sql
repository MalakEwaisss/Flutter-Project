-- ================================================================================
-- FIX RLS POLICIES FOR ADMIN PANEL
-- ================================================================================
-- This allows admin operations to work even when not authenticated via Supabase
-- (since admin uses hardcoded credentials, not Supabase auth)
-- ================================================================================

-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Authenticated users can insert trips" ON trips;
DROP POLICY IF EXISTS "Authenticated users can update trips" ON trips;
DROP POLICY IF EXISTS "Authenticated users can delete trips" ON trips;

-- Create permissive policies that allow operations without auth check
-- NOTE: In production, you should implement proper admin authentication

-- Allow anyone to insert trips (for admin panel)
CREATE POLICY "Allow insert trips"
  ON trips FOR INSERT
  WITH CHECK (true);

-- Allow anyone to update trips (for admin panel)
CREATE POLICY "Allow update trips"
  ON trips FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- Allow anyone to delete trips (for admin panel)
CREATE POLICY "Allow delete trips"
  ON trips FOR DELETE
  USING (true);

-- Verify policies were created
SELECT tablename, policyname, cmd
FROM pg_policies 
WHERE tablename = 'trips'
ORDER BY policyname;
