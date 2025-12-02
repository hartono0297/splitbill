/*
  # Add Bill Description for Share Preview

  1. Changes
    - Add `description` column to `bills` table
      - Optional text field for bill description/notes
      - Will be used in Open Graph meta tags for rich link previews
  
  2. Notes
    - This enhances the sharing experience by providing context
    - Users will see bill title and description when link is shared
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bills' AND column_name = 'description'
  ) THEN
    ALTER TABLE bills ADD COLUMN description text;
  END IF;
END $$;