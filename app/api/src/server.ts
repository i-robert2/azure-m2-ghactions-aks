import express from "express";
import { Pool } from "pg";
import { validateTitle } from "./notes";

const app = express();
app.use(express.json());

const pool = new Pool({
  host: process.env.PG_HOST,
  port: 5432,
  database: process.env.PG_DATABASE ?? "appdb",
  user: process.env.PG_USER,
  password: process.env.PG_PASSWORD,
  ssl: { rejectUnauthorized: false }, // PG Flexible Server requires TLS
});

async function init(): Promise<void> {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS notes (
      id SERIAL PRIMARY KEY,
      title TEXT NOT NULL,
      created_at TIMESTAMPTZ DEFAULT now()
    );
  `);
}

app.get("/api/healthz", (_req, res) => {
  res.json({ status: "ok" });
});

app.get("/api/notes", async (_req, res) => {
  const r = await pool.query("SELECT id, title FROM notes ORDER BY id");
  res.json(r.rows);
});

app.post("/api/notes", async (req, res) => {
  const { title } = req.body ?? {};
  let clean: string;
  try {
    clean = validateTitle(title);
  } catch {
    res.status(400).json({ error: "title required" });
    return;
  }
  const r = await pool.query(
    "INSERT INTO notes (title) VALUES ($1) RETURNING id, title",
    [clean],
  );
  res.status(201).json(r.rows[0]);
});

const port = Number(process.env.PORT ?? 3000);
init()
  .then(() => app.listen(port, () => console.log(`api on ${port}`)))
  .catch((err) => {
    console.error("init failed", err);
    process.exit(1);
  });
