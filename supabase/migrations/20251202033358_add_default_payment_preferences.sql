/*
  # Add Default Payment Method to User Preferences

  1. Changes
    - Add `default_transfer_method` column to store default payment method (bank, ovo, dana, gopay, other)
    - Add `default_bank_name` column to store default bank name
    - Add `default_transfer_account` column to store default account number/ID
    - Add `default_transfer_description` column to store optional description
    
  2. Notes
    - All fields are optional (nullable)
    - These defaults will be shown in PDFs when no payment method is specified for a bill
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_preferences' AND column_name = 'default_transfer_method'
  ) THEN
    ALTER TABLE user_preferences ADD COLUMN default_transfer_method text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_preferences' AND column_name = 'default_bank_name'
  ) THEN
    ALTER TABLE user_preferences ADD COLUMN default_bank_name text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_preferences' AND column_name = 'default_transfer_account'
  ) THEN
    ALTER TABLE user_preferences ADD COLUMN default_transfer_account text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_preferences' AND column_name = 'default_transfer_description'
  ) THEN
    ALTER TABLE user_preferences ADD COLUMN default_transfer_description text;
  END IF;
END $$;