-- ============================================================
-- GRIEER APP — SUPABASE DATENBANK SETUP
-- ============================================================
-- Dieses Script im Supabase SQL-Editor ausführen:
-- https://supabase.com/dashboard → Ihr Projekt → SQL Editor
-- ============================================================

-- Tabelle: Alle gespeicherten Formulare & KVs
CREATE TABLE IF NOT EXISTS grieer_formulare (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  formular_id  TEXT NOT NULL UNIQUE,   -- 'kehr', 'gas', 'pv', 'wprot', etc.
  protokoll_nr TEXT,                   -- Optional: KV-Nr oder Protokoll-Nr
  daten        JSONB NOT NULL,         -- Alle Formular-Felder als JSON
  geraet       TEXT,                   -- Gerät das zuletzt gespeichert hat
  erstellt_am  TIMESTAMPTZ DEFAULT NOW(),
  geaendert_am TIMESTAMPTZ DEFAULT NOW()
);

-- Tabelle: Kundenstammdaten
CREATE TABLE IF NOT EXISTS grieer_kunden (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  kd_nr       TEXT UNIQUE NOT NULL,    -- Kundennummer
  name        TEXT,
  adresse     TEXT,
  plz_ort     TEXT,
  telefon     TEXT,
  email       TEXT,
  notizen     TEXT,
  geaendert_am TIMESTAMPTZ DEFAULT NOW()
);

-- Indizes für schnellen Zugriff
CREATE INDEX IF NOT EXISTS idx_formulare_id ON grieer_formulare(formular_id);
CREATE INDEX IF NOT EXISTS idx_formulare_ts ON grieer_formulare(geaendert_am DESC);
CREATE INDEX IF NOT EXISTS idx_kunden_nr    ON grieer_kunden(kd_nr);

-- RLS deaktivieren (interne Firmen-App, kein Multi-User)
ALTER TABLE grieer_formulare DISABLE ROW LEVEL SECURITY;
ALTER TABLE grieer_kunden    DISABLE ROW LEVEL SECURITY;

-- Automatisches Timestamp-Update
CREATE OR REPLACE FUNCTION update_geaendert_am()
RETURNS TRIGGER AS $$
BEGIN
  NEW.geaendert_am = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER formulare_geaendert
  BEFORE UPDATE ON grieer_formulare
  FOR EACH ROW EXECUTE FUNCTION update_geaendert_am();

CREATE OR REPLACE TRIGGER kunden_geaendert
  BEFORE UPDATE ON grieer_kunden
  FOR EACH ROW EXECUTE FUNCTION update_geaendert_am();

-- Tabellen im API freischalten
GRANT ALL ON grieer_formulare TO anon, authenticated;
GRANT ALL ON grieer_kunden    TO anon, authenticated;

-- ============================================================
-- FERTIG! Jetzt in der Grieer App:
-- ⚙️ Einstellungen → Supabase URL + Anon Key eintragen
-- ============================================================
