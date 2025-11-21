/*
  # Add user authentication to bills

  1. Changes
    - Add `user_id` column to `bills` table to link bills to users
    - Add foreign key constraint to `auth.users`
    - Update RLS policies to ensure users can only access their own bills
    - Add index on user_id for better query performance

  2. Security
    - Users can only view their own bills
    - Users can only create bills for themselves
    - Users can only update their own bills
    - Users can only delete their own bills
*/

-- Add user_id column to bills table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bills' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE bills ADD COLUMN user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Create index on user_id for better performance
CREATE INDEX IF NOT EXISTS bills_user_id_idx ON bills(user_id);

-- Drop existing policies
DROP POLICY IF EXISTS "Anyone can view bills" ON bills;
DROP POLICY IF EXISTS "Anyone can insert bills" ON bills;
DROP POLICY IF EXISTS "Users can view own bills" ON bills;
DROP POLICY IF EXISTS "Users can insert own bills" ON bills;
DROP POLICY IF EXISTS "Users can update own bills" ON bills;
DROP POLICY IF EXISTS "Users can delete own bills" ON bills;

-- Create RLS policies for bills
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

-- Drop existing policies for participants
DROP POLICY IF EXISTS "Anyone can view participants" ON participants;
DROP POLICY IF EXISTS "Anyone can insert participants" ON participants;
DROP POLICY IF EXISTS "Users can view own participants" ON participants;
DROP POLICY IF EXISTS "Users can insert own participants" ON participants;

-- Create RLS policies for participants (access through bills ownership)
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