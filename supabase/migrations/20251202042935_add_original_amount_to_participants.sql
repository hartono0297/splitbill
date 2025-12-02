/*
  # Add Original Amount to Participants

  1. Changes
    - Add `original_amount` column to `participants` table
      - This column stores the participant's share of the original amount before any fees or discounts are applied
      - Used to accurately display "Share of Original Amount" in bill history and PDF views

  2. Notes
    - The `amount` column continues to store the final amount (after discounts and fees)
    - The `original_amount` represents each participant's portion of the bill's `total_amount`
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'participants' AND column_name = 'original_amount'
  ) THEN
    ALTER TABLE participants ADD COLUMN original_amount numeric DEFAULT 0;
  END IF;
END $$;
