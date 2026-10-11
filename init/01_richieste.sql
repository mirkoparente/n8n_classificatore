-- Tabella in cui il workflow salva ogni messaggio classificato
CREATE TABLE IF NOT EXISTS richieste (
    id                 SERIAL PRIMARY KEY,
    messaggio          TEXT,
    categoria          TEXT,
    urgenza            TEXT,
    risposta_suggerita TEXT,
    creato_il          TIMESTAMPTZ DEFAULT now()
);
