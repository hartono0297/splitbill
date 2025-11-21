/*
  # Create Fees Table for Dynamic Fee Management

  1. New Tables
    - `fees`
      - `id` (uuid, primary key)
      - `bill_id` (uuid, foreign key to bills)
      - `name` (text) - Name of the fee (e.g., "Delivery Fee", "Tax")
      - `amount` (numeric) - Amount of the fee
      - `created_at` (timestamptz)
  
  2. Security
    - Enable RLS on `fees` table
    - Add policies for authenticated users to manage their bill fees

  3. Notes
    - Remove old fee columns from bills table (delivery_fee, service_fee, other_fee, other_fee_label)
    - Each bill can have multiple fees with custom names
*/

CREATE TABLE IF NOT EXISTS fees (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bill_id uuid NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
  name text NOT NULL DEFAULT '',
  amount numeric NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE fees ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view fees for their bills"
  ON fees
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = fees.bill_id
      AND bills.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert fees for their bills"
  ON fees
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = fees.bill_id
      AND bills.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update fees for their bills"
  ON fees
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = fees.bill_id
      AND bills.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = fees.bill_id
      AND bills.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete fees for their bills"
  ON fees
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = fees.bill_id
      AND bills.user_id = auth.uid()
    )
  );

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bills' AND column_name = 'delivery_fee'
  ) THEN
    ALTER TABLE bills DROP COLUMN delivery_fee;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bills' AND column_name = 'service_fee'
  ) THEN
    ALTER TABLE bills DROP COLUMN service_fee;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bills' AND column_name = 'other_fee'
  ) THEN
    ALTER TABLE bills DROP COLUMN other_fee;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bills' AND column_name = 'other_fee_label'
  ) THEN
    ALTER TABLE bills DROP COLUMN other_fee_label;
  END IF;
END $$;
