-- ================================================================================
-- ADD MISSING COLUMNS TO user_profiles TABLE
-- ================================================================================
-- This script adds missing columns to the existing user_profiles table
-- Run this in your Supabase SQL Editor
-- ================================================================================

-- Add missing columns to user_profiles table
DO $$ 
BEGIN
  -- Add avatar column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'user_profiles' AND column_name = 'avatar') THEN
    ALTER TABLE user_profiles ADD COLUMN avatar TEXT;
  END IF;
  
  -- Add bio column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'user_profiles' AND column_name = 'bio') THEN
    ALTER TABLE user_profiles ADD COLUMN bio TEXT;
  END IF;
  
  -- Add created_at column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'user_profiles' AND column_name = 'created_at') THEN
    ALTER TABLE user_profiles ADD COLUMN created_at TIMESTAMP DEFAULT NOW();
  END IF;
  
  -- Add updated_at column if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name = 'user_profiles' AND column_name = 'updated_at') THEN
    ALTER TABLE user_profiles ADD COLUMN updated_at TIMESTAMP DEFAULT NOW();
  END IF;
END $$;

-- Verify columns were added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'user_profiles'
ORDER BY ordinal_position;
