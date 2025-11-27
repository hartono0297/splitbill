/*
  # Create Initial Database Schema

  1. New Tables
    - `bills`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to auth.users)
      - `title` (text)
      - `total_amount` (numeric)
      - `discount_percent` (numeric)
      - `max_discount` (numeric)
      - `final_amount` (numeric)
      - `currency` (text)
      - `transfer_method` (text, nullable)
      - `transfer_account` (text, nullable)
      - `transfer_description` (text, nullable)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

    - `participants`
      - `id` (uuid, primary key)
      - `bill_id` (uuid, foreign key to bills)
      - `name` (text)
      - `amount` (numeric)
      - `created_at` (timestamptz)

    - `fees`
      - `id` (uuid, primary key)
      - `bill_id` (uuid, foreign key to bills)
      - `name` (text)
      - `amount` (numeric)
      - `created_at` (timestamptz)

    - `user_preferences`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to auth.users)
      - `currency_format` (text)
      - `dark_mode` (boolean)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

    - `participant_payments`
      - `id` (uuid, primary key)
      - `participant_id` (uuid, foreign key to participants)
      - `bill_id` (uuid, foreign key to bills)
      - `paid` (boolean)
      - `paid_at` (timestamptz, nullable)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

CREATE TABLE IF NOT EXISTS bills (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title text NOT NULL DEFAULT '',
  total_amount numeric NOT NULL DEFAULT 0,
  discount_percent numeric DEFAULT 0,
  max_discount numeric DEFAULT 0,
  final_amount numeric NOT NULL DEFAULT 0,
  currency text DEFAULT 'IDR',
  transfer_method text,
  transfer_account text,
  transfer_description text,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS bills_user_id_idx ON bills(user_id);

ALTER TABLE bills ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own bills"
  ON bills FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own bills"
  ON bills FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own bills"
  ON bills FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own bills"
  ON bills FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS participants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bill_id uuid NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
  name text NOT NULL DEFAULT '',
  amount numeric NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE participants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own participants"
  ON participants FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = participants.bill_id
      AND bills.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own participants"
  ON participants FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = participants.bill_id
      AND bills.user_id = auth.uid()
    )
  );

CREATE TABLE IF NOT EXISTS fees (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bill_id uuid NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
  name text NOT NULL DEFAULT '',
  amount numeric NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE fees ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view fees for their bills"
  ON fees FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = fees.bill_id
      AND bills.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert fees for their bills"
  ON fees FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = fees.bill_id
      AND bills.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update fees for their bills"
  ON fees FOR UPDATE
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
  ON fees FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = fees.bill_id
      AND bills.user_id = auth.uid()
    )
  );

CREATE TABLE IF NOT EXISTS user_preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  currency_format text DEFAULT 'IDR',
  dark_mode boolean DEFAULT false,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own preferences"
  ON user_preferences FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own preferences"
  ON user_preferences FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences"
  ON user_preferences FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS participant_payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_id uuid NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  bill_id uuid NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
  paid boolean DEFAULT false NOT NULL,
  paid_at timestamptz,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE participant_payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view payment status for their bills"
  ON participant_payments FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = participant_payments.bill_id
      AND bills.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create payment records for their bills"
  ON participant_payments FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = participant_payments.bill_id
      AND bills.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update payment status for their bills"
  ON participant_payments FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = participant_payments.bill_id
      AND bills.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = participant_payments.bill_id
      AND bills.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete payment records for their bills"
  ON participant_payments FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = participant_payments.bill_id
      AND bills.user_id = auth.uid()
    )
  );
