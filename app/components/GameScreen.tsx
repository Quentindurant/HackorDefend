"use client";

import { useEffect, useRef, useState } from "react";
import type { AttackCard, Difficulty } from "../data/attacks";

interface Props {
  players: string[];
  scores: number[];
  deck: AttackCard[];
  currentRound: number;
  totalRounds: number;
  difficulty: Difficulty;
  onScore: (playerIndex: number) => void;
  onNext: () => void;
}

export default function GameScreen({ players, scores, deck, currentRound, totalRounds, difficulty, onScore, onNext }: Props) {
  const card = deck[currentRound - 1];
  const [revealed, setRevealed] = useState(false);
  const [scoredSet, setScoredSet] = useState<Set<number>>(new Set());
  const [timeLeft, setTimeLeft] = useState(20);
  const [timerDone, setTimerDone] = useState(false);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const [cardKey, setCardKey] = useState(0);

  // Reset on round change
  useEffect(() => {
    setRevealed(false);
    setScoredSet(new Set());
    setTimeLeft(20);
    setTimerDone(false);
    setCardKey((k) => k + 1);
  }, [currentRound]);

  // Timer for expert mode
  useEffect(() => {
    if (difficulty !== "expert" || revealed) return;
    timerRef.current = setInterval(() => {
      setTimeLeft((t) => {
        if (t <= 1) {
          clearInterval(timerRef.current!);
          setTimerDone(true);
          setRevealed(true);
          return 0;
        }
        return t - 1;
      });
    }, 1000);
    return () => clearInterval(timerRef.current!);
  }, [currentRound, difficulty, revealed]);

  function handleReveal() {
    if (timerRef.current) clearInterval(timerRef.current);
    setRevealed(true);
  }

  function toggleScore(i: number) {
    if (!revealed) return;
    if (scoredSet.has(i)) {
      setScoredSet((prev) => { const n = new Set(prev); n.delete(i); return n; });
      onScore(-(i + 100));
    } else {
      setScoredSet((prev) => { const n = new Set(prev); n.add(i); return n; });
      onScore(i);
    }
  }

  const timerPct = (timeLeft / 20) * 100;
  const timerColor = timeLeft > 10 ? "var(--green)" : timeLeft > 5 ? "var(--orange)" : "var(--red)";
  const timerClass = timeLeft <= 5 && !revealed ? "animate-pulse-danger" : "";

  return (
    <div className="min-h-screen flex flex-col items-center px-4 py-6" style={{ background: "var(--bg)" }}>
      <h1 className="text-2xl font-black mb-4 tracking-tight" style={{ background: "linear-gradient(135deg, var(--cyan), var(--green))", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>
        HACK <span style={{ WebkitTextFillColor: "var(--red)" }}>or</span> DEFEND
      </h1>

      {/* Game header bar */}
      <div className="w-full max-w-2xl flex items-center justify-between rounded-xl px-5 py-3 mb-5 border"
        style={{ background: "var(--surface)", borderColor: "var(--border)" }}>
        <div className="text-sm" style={{ color: "var(--muted)" }}>
          Round <span className="text-xl font-black" style={{ color: "var(--cyan)" }}>{currentRound}</span>
          <span className="ml-1">/ {totalRounds}</span>
        </div>
        <div className="flex gap-3 flex-wrap justify-end">
          {players.map((p, i) => (
            <div key={i} className="rounded-full px-3 py-1 text-sm border"
              style={{ background: "var(--surface2)", borderColor: "var(--border)" }}>
              <span style={{ color: "var(--muted)" }}>{p.split(" ")[0]}</span>
              <span className="ml-1 font-bold" style={{ color: "var(--cyan)" }}>{scores[i]}</span>
            </div>
          ))}
        </div>
      </div>

      <div className="w-full max-w-2xl space-y-4">
        {/* Timer bar (expert only) */}
        {difficulty === "expert" && (
          <div>
            <div className={`text-center text-4xl font-black tabular-nums mb-2 ${timerClass}`} style={{ color: timerColor }}>
              {timerDone ? "TIME'S UP" : String(timeLeft).padStart(2, "0")}
            </div>
            <div className="h-2 rounded-full overflow-hidden" style={{ background: "var(--surface2)" }}>
              <div className="h-full rounded-full transition-all duration-1000"
                style={{ width: `${timerPct}%`, background: timerColor }} />
            </div>
          </div>
        )}

        {/* Attack card */}
        <div key={cardKey} className="rounded-2xl p-7 border-2 animate-fade-up relative overflow-hidden"
          style={{ background: "var(--surface)", borderColor: "rgba(255,64,96,0.35)" }}>
          <div className="absolute top-0 left-0 right-0 h-1 rounded-t-2xl"
            style={{ background: "linear-gradient(90deg, var(--red), var(--orange))" }} />
          <div className="inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-bold uppercase tracking-widest mb-4 border"
            style={{ background: "rgba(255,64,96,0.1)", borderColor: "rgba(255,64,96,0.4)", color: "var(--red)" }}>
            ⚡ Cyber Attack
          </div>
          <h2 className="text-2xl font-black mb-3">{card.name}</h2>
          <p className="leading-relaxed" style={{ color: "#c5ddf0", fontSize: "1.05rem" }}>{card.scenario}</p>
          <div className="flex items-center gap-3 mt-4 flex-wrap">
            <span className="tag-category rounded-md px-2 py-1 text-xs border">
              {card.category}
            </span>
            {difficulty === "beginner" && (
              <span className="tag-hint rounded-md px-3 py-1 text-xs border font-medium">
                💡 {card.hint}
              </span>
            )}
          </div>
        </div>

        {/* Reveal button */}
        {!revealed && (
          <button onClick={handleReveal}
            className="w-full py-4 rounded-xl font-bold text-lg cursor-pointer transition-all hover:opacity-90 active:scale-95"
            style={{ background: "linear-gradient(135deg, var(--red), #cc2040)", color: "#fff" }}>
            🔓 Reveal Answer
          </button>
        )}

        {/* Defense card */}
        {revealed && (
          <div className="rounded-2xl p-6 border-2 animate-slide-in relative overflow-hidden"
            style={{ background: "var(--surface)", borderColor: "rgba(0,232,150,0.35)" }}>
            <div className="absolute top-0 left-0 right-0 h-1 rounded-t-2xl"
              style={{ background: "linear-gradient(90deg, var(--green), var(--cyan))" }} />
            <div className="inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-bold uppercase tracking-widest mb-3 border"
              style={{ background: "rgba(0,232,150,0.1)", borderColor: "rgba(0,232,150,0.3)", color: "var(--green)" }}>
              🛡 Correct Defense
            </div>
            <h3 className="text-xl font-bold mb-2" style={{ color: "var(--green)" }}>{card.defense}</h3>
            <p className="leading-relaxed text-sm" style={{ color: "#c5ddf0" }}>{card.explanation}</p>
          </div>
        )}

        {/* Score controls */}
        {revealed && (
          <div className="rounded-2xl p-5 border animate-fade-up"
            style={{ background: "var(--surface)", borderColor: "var(--border)" }}>
            <p className="text-xs font-bold uppercase tracking-widest mb-4" style={{ color: "var(--muted)" }}>
              Who got it right? (tap to toggle +1)
            </p>
            <div className="grid gap-3" style={{ gridTemplateColumns: `repeat(${players.length}, 1fr)` }}>
              {players.map((p, i) => (
                <button key={i} onClick={() => toggleScore(i)}
                  className="rounded-xl p-4 text-center cursor-pointer transition-all border-2"
                  style={{
                    background: scoredSet.has(i) ? "rgba(0,232,150,0.1)" : "var(--surface2)",
                    borderColor: scoredSet.has(i) ? "var(--green)" : "var(--border)",
                  }}>
                  <div className="font-semibold text-sm truncate">{p}</div>
                  <div className="text-2xl font-black mt-1" style={{ color: "var(--cyan)" }}>{scores[i]}</div>
                  {scoredSet.has(i) && <div className="text-xs mt-1" style={{ color: "var(--green)" }}>✓ +1</div>}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Next / End button */}
        {revealed && (
          <button onClick={onNext}
            className="w-full py-4 rounded-xl font-bold text-lg cursor-pointer transition-all hover:opacity-90 active:scale-95 border-2"
            style={{ background: "transparent", borderColor: "var(--border)", color: "var(--text)" }}>
            {currentRound >= totalRounds ? "See Results →" : "Next Round →"}
          </button>
        )}
      </div>
    </div>
  );
}
