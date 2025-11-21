/*
  # Add Dark Mode Preference

  1. Changes
    - Add `dark_mode` column to `user_preferences` table
    - Default value is false (light mode)
  
  2. Notes
    - Users can toggle between light and dark mode
    - Preference is stored per user
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_preferences' AND column_name = 'dark_mode'
  ) THEN
    ALTER TABLE user_preferences ADD COLUMN dark_mode boolean NOT NULL DEFAULT false;
  END IF;
END $$;
