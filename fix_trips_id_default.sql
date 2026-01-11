-- ================================================================================
-- FIX TRIPS TABLE ID COLUMN TO AUTO-GENERATE UUID
-- ================================================================================
-- This adds a default UUID generator to the id column
-- ================================================================================

-- Add default UUID generation to the id column
ALTER TABLE trips 
ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- Verify the change
SELECT column_name, column_default, is_nullable
FROM information_schema.columns 
WHERE table_name = 'trips' AND column_name = 'id';
