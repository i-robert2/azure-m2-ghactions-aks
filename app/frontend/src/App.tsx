import { useEffect, useState } from "react";

type Note = { id: number; title: string };

export default function App() {
  const [notes, setNotes] = useState<Note[]>([]);
  const [title, setTitle] = useState("");

  useEffect(() => {
    fetch("/api/notes")
      .then((r) => r.json())
      .then(setNotes)
      .catch(() => setNotes([]));
  }, []);

  const add = async () => {
    if (!title.trim()) return;
    const r = await fetch("/api/notes", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ title }),
    });
    if (r.ok) {
      const n = await r.json();
      setNotes([...notes, n]);
      setTitle("");
    }
  };

  return (
    <main style={{ fontFamily: "system-ui, sans-serif", padding: 24, maxWidth: 640, margin: "0 auto" }}>
      <h1>Notes (M1)</h1>
      <p>React frontend &rarr; Node API &rarr; PostgreSQL, on AKS.</p>
      <div style={{ display: "flex", gap: 8 }}>
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Note title"
          onKeyDown={(e) => e.key === "Enter" && add()}
          style={{ flex: 1, padding: 8 }}
        />
        <button onClick={add} style={{ padding: "8px 16px" }}>Add</button>
      </div>
      <ul>
        {notes.map((n) => (
          <li key={n.id}>{n.title}</li>
        ))}
      </ul>
    </main>
  );
}
