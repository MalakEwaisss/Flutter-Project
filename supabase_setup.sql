-- ================================================================================
-- SUPABASE TABLES SETUP FOR TRIP BOOKING APP
-- ================================================================================
-- Instructions:
-- 1. Go to your Supabase dashboard: https://supabase.com/dashboard
-- 2. Select your project: jofcdkdoxhkjejgkdrbk
-- 3. Click on "SQL Editor" in the left sidebar
-- 4. Copy and paste this entire file
-- 5. Click "Run" to execute
-- ================================================================================

-- TABLE 1: FAVORITES
-- Purpose: Store user's favorite trips
CREATE TABLE IF NOT EXISTS favorites (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  trip_id TEXT NOT NULL,
  trip_name TEXT NOT NULL,
  trip_location TEXT NOT NULL,
  trip_price INTEGER NOT NULL,
  trip_image TEXT,
  favorited_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, trip_id)
);

-- Enable Row Level Security (RLS) for favorites
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid errors on re-run)
DROP POLICY IF EXISTS "Users can view their own favorites" ON favorites;
DROP POLICY IF EXISTS "Users can insert their own favorites" ON favorites;
DROP POLICY IF EXISTS "Users can delete their own favorites" ON favorites;

-- RLS Policy: Users can only see their own favorites
CREATE POLICY "Users can view their own favorites"
  ON favorites FOR SELECT
  USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own favorites
CREATE POLICY "Users can insert their own favorites"
  ON favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can delete their own favorites
CREATE POLICY "Users can delete their own favorites"
  ON favorites FOR DELETE
  USING (auth.uid() = user_id);

-- ================================================================================

-- TABLE 2: BOOKINGS
-- Purpose: Store confirmed trip bookings
CREATE TABLE IF NOT EXISTS bookings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  trip_id TEXT NOT NULL,
  trip_name TEXT NOT NULL,
  location TEXT NOT NULL,
  number_of_guests INTEGER NOT NULL CHECK (number_of_guests >= 1),
  special_requests TEXT,
  total_price INTEGER NOT NULL,
  booking_date TIMESTAMP DEFAULT NOW()
);

-- Add missing columns to existing bookings table (if table already exists)
DO $$ 
BEGIN
  -- Add trip_id column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'bookings' AND column_name = 'trip_id') THEN
    ALTER TABLE bookings ADD COLUMN trip_id TEXT;
  END IF;
  
  -- Add trip_name column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'bookings' AND column_name = 'trip_name') THEN
    ALTER TABLE bookings ADD COLUMN trip_name TEXT;
  END IF;
  
  -- Add location column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'bookings' AND column_name = 'location') THEN
    ALTER TABLE bookings ADD COLUMN location TEXT;
  END IF;
  
  -- Add number_of_guests column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'bookings' AND column_name = 'number_of_guests') THEN
    ALTER TABLE bookings ADD COLUMN number_of_guests INTEGER;
  END IF;
  
  -- Add special_requests column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'bookings' AND column_name = 'special_requests') THEN
    ALTER TABLE bookings ADD COLUMN special_requests TEXT;
  END IF;
  
  -- Add total_price column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'bookings' AND column_name = 'total_price') THEN
    ALTER TABLE bookings ADD COLUMN total_price INTEGER;
  END IF;
  
  -- Add trip_image column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'bookings' AND column_name = 'trip_image') THEN
    ALTER TABLE bookings ADD COLUMN trip_image TEXT;
  END IF;
  
  -- Add travel_date column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'bookings' AND column_name = 'travel_date') THEN
    ALTER TABLE bookings ADD COLUMN travel_date DATE;
  END IF;
  
  -- Add seat_category column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'bookings' AND column_name = 'seat_category') THEN
    ALTER TABLE bookings ADD COLUMN seat_category TEXT;
  END IF;
  
  -- Add seat_number column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'bookings' AND column_name = 'seat_number') THEN
    ALTER TABLE bookings ADD COLUMN seat_number TEXT;
  END IF;
  
  -- Add booking_date column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'bookings' AND column_name = 'booking_date') THEN
    ALTER TABLE bookings ADD COLUMN booking_date TIMESTAMP DEFAULT NOW();
  END IF;
END $$;

-- Enable Row Level Security (RLS) for bookings
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid errors on re-run)
DROP POLICY IF EXISTS "Users can view their own bookings" ON bookings;
DROP POLICY IF EXISTS "Users can insert their own bookings" ON bookings;
DROP POLICY IF EXISTS "Users can delete their own bookings" ON bookings;

-- RLS Policy: Users can only see their own bookings
CREATE POLICY "Users can view their own bookings"
  ON bookings FOR SELECT
  USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own bookings
CREATE POLICY "Users can insert their own bookings"
  ON bookings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can delete their own bookings
CREATE POLICY "Users can delete their own bookings"
  ON bookings FOR DELETE
  USING (auth.uid() = user_id);

-- ================================================================================
-- INDEXES FOR BETTER QUERY PERFORMANCE
-- ================================================================================

-- Index on favorites for faster lookups by user
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id);

-- Index on favorites for checking if a trip is favorited
CREATE INDEX IF NOT EXISTS idx_favorites_user_trip ON favorites(user_id, trip_id);

-- Index on bookings for faster lookups by user
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);

-- Index on bookings for date-based queries
CREATE INDEX IF NOT EXISTS idx_bookings_date ON bookings(booking_date DESC);

-- ================================================================================
-- VERIFICATION QUERIES (Run these after setup to confirm)
-- ================================================================================

-- Check if favorites table was created
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'favorites' 
ORDER BY ordinal_position;

-- Check if bookings table was created
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'bookings' 
ORDER BY ordinal_position;

-- Check RLS policies
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('favorites', 'bookings');
