-- ================================================================================
-- ADMIN PANEL SETUP FOR TRIP BOOKING APP
-- ================================================================================
-- Instructions:
-- 1. Go to your Supabase dashboard: https://supabase.com/dashboard
-- 2. Select your project: jofcdkdoxhkjejgkdrbk
-- 3. Click on "SQL Editor" in the left sidebar
-- 4. Copy and paste this entire file
-- 5. Click "Run" to execute
-- ================================================================================

-- TABLE 1: TRIPS
-- Purpose: Store all trip data for the application
CREATE TABLE IF NOT EXISTS trips (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  location TEXT NOT NULL,
  rating NUMERIC(2, 1) DEFAULT 0.0,
  reviews INTEGER DEFAULT 0,
  price INTEGER NOT NULL,
  date TEXT NOT NULL,
  image TEXT,
  airline TEXT,
  aircraft TEXT,
  class TEXT,
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable Row Level Security (RLS) for trips
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid errors on re-run)
DROP POLICY IF EXISTS "Anyone can view trips" ON trips;
DROP POLICY IF EXISTS "Only authenticated users can insert trips" ON trips;
DROP POLICY IF EXISTS "Only authenticated users can update trips" ON trips;
DROP POLICY IF EXISTS "Only authenticated users can delete trips" ON trips;

-- RLS Policy: Anyone can view trips (public access)
CREATE POLICY "Anyone can view trips"
  ON trips FOR SELECT
  USING (true);

-- RLS Policy: Only authenticated users can insert trips
-- (In practice, only admin will do this from the app)
CREATE POLICY "Only authenticated users can insert trips"
  ON trips FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- RLS Policy: Only authenticated users can update trips
CREATE POLICY "Only authenticated users can update trips"
  ON trips FOR UPDATE
  USING (auth.uid() IS NOT NULL);

-- RLS Policy: Only authenticated users can delete trips
CREATE POLICY "Only authenticated users can delete trips"
  ON trips FOR DELETE
  USING (auth.uid() IS NOT NULL);

-- ================================================================================
-- TABLE 2: PROFILES (Extended user information)
-- Purpose: Store additional user profile data beyond Supabase Auth
-- ================================================================================

-- Create profiles table if it doesn't exist
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  avatar TEXT,
  bio TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Add missing columns to existing profiles table (if table already exists)
DO $$ 
BEGIN
  -- Add name column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'profiles' AND column_name = 'name') THEN
    ALTER TABLE profiles ADD COLUMN name TEXT;
  END IF;
  
  -- Add email column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'profiles' AND column_name = 'email') THEN
    ALTER TABLE profiles ADD COLUMN email TEXT;
  END IF;
  
  -- Add avatar column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'profiles' AND column_name = 'avatar') THEN
    ALTER TABLE profiles ADD COLUMN avatar TEXT;
  END IF;
  
  -- Add bio column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'profiles' AND column_name = 'bio') THEN
    ALTER TABLE profiles ADD COLUMN bio TEXT;
  END IF;
  
  -- Add created_at column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'profiles' AND column_name = 'created_at') THEN
    ALTER TABLE profiles ADD COLUMN created_at TIMESTAMP DEFAULT NOW();
  END IF;
  
  -- Add updated_at column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'profiles' AND column_name = 'updated_at') THEN
    ALTER TABLE profiles ADD COLUMN updated_at TIMESTAMP DEFAULT NOW();
  END IF;
END $$;

-- Enable Row Level Security (RLS) for profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

-- RLS Policy: Anyone can view user profiles
CREATE POLICY "Users can view all profiles"
  ON profiles FOR SELECT
  USING (true);

-- RLS Policy: Users can insert their own profile
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- RLS Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- ================================================================================
-- FUNCTION: Auto-update updated_at timestamp
-- ================================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for trips table
DROP TRIGGER IF EXISTS update_trips_updated_at ON trips;
CREATE TRIGGER update_trips_updated_at
  BEFORE UPDATE ON trips
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for profiles table
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ================================================================================
-- INDEXES FOR BETTER QUERY PERFORMANCE
-- ================================================================================

-- Index on trips for faster lookups by location
CREATE INDEX IF NOT EXISTS idx_trips_location ON trips(location);

-- Index on trips for price-based queries
CREATE INDEX IF NOT EXISTS idx_trips_price ON trips(price);

-- Index on trips for rating-based queries
CREATE INDEX IF NOT EXISTS idx_trips_rating ON trips(rating DESC);

-- Index on profiles for email lookups
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);

-- ================================================================================
-- SEED DATA: Insert sample trips from existing trip_data.dart
-- ================================================================================

INSERT INTO trips (id, title, location, rating, reviews, price, date, image, airline, aircraft, class, description)
VALUES 
  (
    '00000000-0000-0000-0000-000000000001',
    'Bali Beach Paradise',
    'Bali, Indonesia',
    4.9,
    328,
    1299,
    'Mar 15 - Mar 22',
    'https://images.unsplash.com/photo-1577717903315-1691ae25ab3f?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'Garuda Indonesia',
    'Boeing 787 Dreamliner',
    'Business Class',
    'Experience the ultimate tropical getaway with pristine beaches and vibrant culture.'
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    'European Escapade',
    'Paris & Rome',
    4.8,
    436,
    1899,
    'Apr 10 - Apr 20',
    'https://images.unsplash.com/photo-1473951574080-01fe45ec8643?q=80&w=2104&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'Air France',
    'Airbus A350-900',
    'Economy Plus',
    'A journey through the heart of Europe''s most romantic and historic cities.'
  ),
  (
    '00000000-0000-0000-0000-000000000003',
    'Mountain Adventure',
    'Swiss Alps',
    4.7,
    234,
    1599,
    'May 5 - May 12',
    'https://images.unsplash.com/photo-1586752488885-6ce47fdfd874?q=80&w=2113&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'Swiss Air',
    'Airbus A330',
    'Normal Chair',
    'Breathtaking views and world-class skiing in the heart of the Alps.'
  ),
  (
    '00000000-0000-0000-0000-000000000004',
    'Tokyo Modern',
    'Tokyo, Japan',
    4.9,
    512,
    1799,
    'Jun 1 - Jun 10',
    'https://images.unsplash.com/photo-1617869884925-f8f0a51b2374?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'Japan Airlines',
    'Boeing 777',
    'First Class',
    'Explore the neon lights and ancient temples of Japan''s bustling capital.'
  ),
  (
    '00000000-0000-0000-0000-000000000005',
    'Pyramids of Giza',
    'Giza, Egypt',
    4.9,
    782,
    1499,
    'Jul 8 - Jul 18',
    'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=2070&auto=format&fit=crop',
    'EgyptAir',
    'Boeing 787',
    'Business Class',
    'Witness the last standing wonder of the ancient world and explore ancient Egyptian civilization.'
  )
ON CONFLICT (id) DO NOTHING;

-- ================================================================================
-- VERIFICATION QUERIES (Run these after setup to confirm)
-- ================================================================================

-- Check if trips table was created
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'trips' 
ORDER BY ordinal_position;

-- Check if profiles table was created
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

-- Check RLS policies
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('trips', 'profiles');

-- Verify sample trips were inserted
SELECT id, title, location, price FROM trips;
