# Classificatore di messaggi con n8n, Ollama e PostgreSQL

Workflow [n8n](https://n8n.io) che riceve il messaggio di un cliente tramite webhook, lo fa classificare da un
LLM locale ([Ollama](https://ollama.com)) e salva il risultato su PostgreSQL.
È usato come strumento dall'assistente multi-agente [Jarvis](https://github.com/mirkoparente/Jarvis-langgraph).

## Flusso

```
POST /webhook/chiedi  ──▶  Ollama (qwen3:8b)  ──▶  PostgreSQL (tabella richieste)  ──▶  risposta JSON
{"messaggio": "..."}       categoria, urgenza,      salva messaggio e classificazione
                           risposta suggerita
```

Il modello restituisce un JSON con:
- `categoria`: `fatturazione`, `guasto`, `cambio_offerta`, `altro`
- `urgenza`: `bassa`, `media`, `alta`
- `risposta_suggerita`: massimo due frasi

## Contenuto

| File | Descrizione |
| --- | --- |
| `docker-compose.yml` | n8n + PostgreSQL |
| `workflows/classificatore.json` | Workflow da importare in n8n |
| `init/01_richieste.sql` | Crea la tabella `richieste` al primo avvio del database |
| `.env.example` | Variabili d'ambiente (password del database) |

## Avvio

Requisiti: Docker e Ollama in esecuzione sul PC con il modello `qwen3:8b` (`ollama pull qwen3:8b`).

```bash
cp .env.example .env        # imposta una password
docker compose up -d
```

Poi su http://localhost:5678:

1. crea l'account di n8n;
2. importa `workflows/classificatore.json` (menu del workflow → *Import from File*);
3. nel nodo Postgres crea la credenziale: host `postgres`, database `n8n`, utente `n8n`, password quella del `.env`;
4. pubblica il workflow (**Publish**).

## Prova

```bash
curl -X POST http://localhost:5678/webhook/chiedi \
  -H "Content-Type: application/json" \
  -d '{"messaggio": "Mi è arrivata una bolletta di 400 euro, è un errore?"}'
```

Usa l'URL `/webhook/` (produzione, workflow pubblicato), non `/webhook-test/`, che risponde solo mentre il
workflow è in ascolto nell'editor.

## Note

- n8n raggiunge Ollama sul PC tramite `host.docker.internal`.
- Il webhook non ha autenticazione: è pensato per l'uso in locale.
