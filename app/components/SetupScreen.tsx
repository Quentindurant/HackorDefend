"use client";

import { useState } from "react";
import type { Difficulty } from "../data/attacks";

interface Props {
  onStart: (players: string[], difficulty: Difficulty) => void;
}

const DIFFICULTIES: { value: Difficulty; label: string; icon: string; desc: string }[] = [
  { value: "beginner",     label: "Beginner",     icon: "🟢", desc: "No timer · hints shown" },
  { value: "intermediate", label: "Intermediate", icon: "🟡", desc: "No timer · no hints" },
  { value: "expert",       label: "Expert",       icon: "🔴", desc: "20s timer · no hints" },
];

export default function SetupScreen({ onStart }: Props) {
  const [difficulty, setDifficulty] = useState<Difficulty>("beginner");
  const [playerCount, setPlayerCount] = useState(3);
  const [names, setNames] = useState<string[]>(["", "", "", ""]);

  function updateName(i: number, val: string) {
    setNames((prev) => { const n = [...prev]; n[i] = val; return n; });
  }

  function handleStart() {
    const players = Array.from({ length: playerCount }, (_, i) => names[i]?.trim() || `Player ${i + 1}`);
    onStart(players, difficulty);
  }

  return (
    <div className="min-h-screen flex flex-col items-center px-4 py-10" style={{ background: "var(--bg)" }}>
      {/* Header */}
      <header className="text-center mb-10">
        <h1 className="text-5xl font-black tracking-tight" style={{ background: "linear-gradient(135deg, var(--cyan), var(--green))", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>
          HACK <span style={{ WebkitTextFillColor: "var(--red)" }}>or</span> DEFEND
        </h1>
        <p className="mt-2 text-sm tracking-widest uppercase" style={{ color: "var(--muted)" }}>
          Cybersecurity Serious Game · Digital Companion
        </p>
      </header>

      <div className="w-full max-w-xl space-y-8">
        {/* Difficulty */}
        <section>
          <p className="text-xs font-bold uppercase tracking-widest mb-3" style={{ color: "var(--muted)" }}>Difficulty</p>
          <div className="grid grid-cols-3 gap-3">
            {DIFFICULTIES.map((d) => (
              <button
                key={d.value}
                onClick={() => setDifficulty(d.value)}
                className="rounded-xl p-4 text-center transition-all border-2 cursor-pointer"
                style={{
                  background: difficulty === d.value ? "rgba(0,212,255,0.08)" : "var(--surface)",
                  borderColor: difficulty === d.value ? "var(--cyan)" : "var(--border)",
                  color: "var(--text)",
                }}
              >
                <div className="text-2xl mb-1">{d.icon}</div>
                <div className="font-bold text-sm">{d.label}</div>
                <div className="text-xs mt-1" style={{ color: "var(--muted)" }}>{d.desc}</div>
              </button>
            ))}
          </div>
        </section>

        {/* Player count */}
        <section>
          <p className="text-xs font-bold uppercase tracking-widest mb-3" style={{ color: "var(--muted)" }}>Number of Players</p>
          <div className="flex gap-3">
            {[2, 3, 4].map((n) => (
              <button
                key={n}
                onClick={() => setPlayerCount(n)}
                className="w-14 h-14 rounded-full font-bold text-xl transition-all border-2 cursor-pointer"
                style={{
                  background: playerCount === n ? "rgba(0,212,255,0.1)" : "var(--surface)",
                  borderColor: playerCount === n ? "var(--cyan)" : "var(--border)",
                  color: playerCount === n ? "var(--cyan)" : "var(--text)",
                }}
              >
                {n}
              </button>
            ))}
          </div>
        </section>

        {/* Player names */}
        <section>
          <p className="text-xs font-bold uppercase tracking-widest mb-3" style={{ color: "var(--muted)" }}>Player Names</p>
          <div className="space-y-3">
            {Array.from({ length: playerCount }).map((_, i) => (
              <input
                key={i}
                type="text"
                placeholder={`Player ${i + 1}`}
                value={names[i] || ""}
                onChange={(e) => updateName(i, e.target.value)}
                className="w-full rounded-xl px-4 py-3 text-sm font-medium outline-none transition-all border-2"
                style={{
                  background: "var(--surface)",
                  borderColor: "var(--border)",
                  color: "var(--text)",
                }}
                onFocus={(e) => (e.target.style.borderColor = "var(--cyan)")}
                onBlur={(e) => (e.target.style.borderColor = "var(--border)")}
              />
            ))}
          </div>
        </section>

        {/* Start button */}
        <button
          onClick={handleStart}
          className="w-full py-4 rounded-xl font-bold text-lg tracking-wide cursor-pointer transition-all hover:opacity-90 active:scale-95"
          style={{ background: "linear-gradient(135deg, var(--cyan), #0099cc)", color: "#000" }}
        >
          START GAME →
        </button>
      </div>
    </div>
  );
}
