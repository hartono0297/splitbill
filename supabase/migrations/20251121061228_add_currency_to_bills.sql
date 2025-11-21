/*
  # Add Currency Field to Bills

  1. Changes
    - Add `currency` column to `bills` table
    - Default value is 'IDR' for existing bills
    - Stores the currency used when the bill was created
  
  2. Notes
    - This allows each bill to remember its original currency
    - Bills in history will display in their original currency
    - Dashboard stats can be converted to current preference
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bills' AND column_name = 'currency'
  ) THEN
    ALTER TABLE bills ADD COLUMN currency text NOT NULL DEFAULT 'IDR';
  END IF;
END $$;
