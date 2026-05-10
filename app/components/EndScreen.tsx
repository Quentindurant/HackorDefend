"use client";

interface Props {
  players: string[];
  scores: number[];
  onPlayAgain: () => void;
  onSetup: () => void;
}

const MEDALS = ["🥇", "🥈", "🥉"];
const RANK_COLORS = ["#ffd700", "#c0c0c0", "#cd7f32"];

export default function EndScreen({ players, scores, onPlayAgain, onSetup }: Props) {
  const ranked = players
    .map((name, i) => ({ name, score: scores[i] }))
    .sort((a, b) => b.score - a.score);

  const winner = ranked[0];

  return (
    <div className="min-h-screen flex flex-col items-center px-4 py-10" style={{ background: "var(--bg)" }}>
      <h1 className="text-3xl font-black tracking-tight mb-2"
        style={{ background: "linear-gradient(135deg, var(--cyan), var(--green))", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>
        HACK <span style={{ WebkitTextFillColor: "var(--red)" }}>or</span> DEFEND
      </h1>
      <p className="text-sm uppercase tracking-widest mb-8" style={{ color: "var(--muted)" }}>Game Over</p>

      <div className="w-full max-w-xl space-y-5">
        {/* Winner */}
        <div className="rounded-2xl p-8 text-center border-2 animate-fade-up"
          style={{ background: "linear-gradient(135deg, rgba(0,212,255,0.08), rgba(0,232,150,0.08))", borderColor: "var(--cyan)" }}>
          <div className="text-6xl mb-3">👑</div>
          <div className="text-3xl font-black" style={{ color: "var(--cyan)" }}>{winner.name}</div>
          <div className="mt-2 text-sm" style={{ color: "var(--muted)" }}>{winner.score} point{winner.score !== 1 ? "s" : ""} scored</div>
        </div>

        {/* Rankings */}
        <div className="space-y-3">
          {ranked.map((p, i) => (
            <div key={i} className="flex items-center justify-between rounded-xl px-5 py-4 border animate-slide-in"
              style={{ background: "var(--surface)", borderColor: "var(--border)", animationDelay: `${i * 60}ms` }}>
              <span className="text-xl font-black w-10" style={{ color: RANK_COLORS[i] ?? "var(--muted)" }}>
                {MEDALS[i] ?? i + 1}
              </span>
              <span className="flex-1 ml-3 font-semibold">{p.name}</span>
              <span className="text-2xl font-black" style={{ color: "var(--cyan)" }}>{p.score} pts</span>
            </div>
          ))}
        </div>

        {/* Actions */}
        <div className="flex gap-3 pt-2">
          <button onClick={onPlayAgain}
            className="flex-1 py-4 rounded-xl font-bold text-base cursor-pointer transition-all hover:opacity-90 active:scale-95"
            style={{ background: "linear-gradient(135deg, var(--cyan), #0099cc)", color: "#000" }}>
            Play Again
          </button>
          <button onClick={onSetup}
            className="flex-1 py-4 rounded-xl font-bold text-base cursor-pointer transition-all hover:opacity-90 active:scale-95 border-2"
            style={{ background: "transparent", borderColor: "var(--border)", color: "var(--text)" }}>
            Change Settings
          </button>
        </div>
      </div>
    </div>
  );
}
