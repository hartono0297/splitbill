/*
  # Add Additional Fees to Bills

  1. Changes
    - Add `delivery_fee` column to bills table (numeric, default 0)
    - Add `service_fee` column to bills table (numeric, default 0)
    - Add `other_fee` column to bills table (numeric, default 0)
    - Add `other_fee_label` column to bills table (text, default '')
    
  2. Notes
    - These fees are added to the final amount after discount
    - Fees are optional and default to 0
    - other_fee_label allows custom naming for additional fees
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bills' AND column_name = 'delivery_fee'
  ) THEN
    ALTER TABLE bills ADD COLUMN delivery_fee numeric DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bills' AND column_name = 'service_fee'
  ) THEN
    ALTER TABLE bills ADD COLUMN service_fee numeric DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bills' AND column_name = 'other_fee'
  ) THEN
    ALTER TABLE bills ADD COLUMN other_fee numeric DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bills' AND column_name = 'other_fee_label'
  ) THEN
    ALTER TABLE bills ADD COLUMN other_fee_label text DEFAULT '';
  END IF;
END $$;
