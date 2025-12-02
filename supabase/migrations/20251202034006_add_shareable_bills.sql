/*
  # Add Shareable Bills Feature

  1. Changes
    - Add `is_public` column to track if a bill can be viewed publicly
    - Add `share_token` column to store unique share token for public access
    
  2. Security
    - Share token is unique and used for public access without authentication
    - Only bills with is_public = true can be accessed publicly
    - Add RLS policy to allow public read access for bills with valid share token
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bills' AND column_name = 'is_public'
  ) THEN
    ALTER TABLE bills ADD COLUMN is_public boolean DEFAULT false;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bills' AND column_name = 'share_token'
  ) THEN
    ALTER TABLE bills ADD COLUMN share_token text UNIQUE;
  END IF;
END $$;

DROP POLICY IF EXISTS "Allow public read access to shared bills" ON bills;
CREATE POLICY "Allow public read access to shared bills"
  ON bills
  FOR SELECT
  TO anon
  USING (is_public = true AND share_token IS NOT NULL);

DROP POLICY IF EXISTS "Allow public read access to shared participants" ON participants;
CREATE POLICY "Allow public read access to shared participants"
  ON participants
  FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = participants.bill_id
      AND bills.is_public = true
      AND bills.share_token IS NOT NULL
    )
  );

DROP POLICY IF EXISTS "Allow public read access to shared fees" ON fees;
CREATE POLICY "Allow public read access to shared fees"
  ON fees
  FOR SELECT
  TO anon
  USING (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = fees.bill_id
      AND bills.is_public = true
      AND bills.share_token IS NOT NULL
    )
  );