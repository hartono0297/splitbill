/*
  # Add Bank Name Field to Bills

  1. Changes
    - Add `bank_name` column to bills table for storing bank name when transfer method is bank account

  2. Notes
    - Optional field that appears when user selects Bank Account as transfer method
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bills' AND column_name = 'bank_name'
  ) THEN
    ALTER TABLE bills ADD COLUMN bank_name text;
  END IF;
END $$;
