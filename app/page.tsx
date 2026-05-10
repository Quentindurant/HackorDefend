"use client";

import { useState, useCallback } from "react";
import { ATTACKS, type Difficulty } from "./data/attacks";
import SetupScreen from "./components/SetupScreen";
import GameScreen from "./components/GameScreen";
import EndScreen from "./components/EndScreen";

type Screen = "setup" | "game" | "end";

interface GameState {
  players: string[];
  scores: number[];
  deck: typeof ATTACKS;
  currentRound: number;
  totalRounds: number;
  difficulty: Difficulty;
}

function shuffled<T>(arr: T[]): T[] {
  return [...arr].sort(() => Math.random() - 0.5);
}

export default function Page() {
  const [screen, setScreen] = useState<Screen>("setup");
  const [game, setGame] = useState<GameState | null>(null);

  function handleStart(players: string[], difficulty: Difficulty) {
    const deck = shuffled(ATTACKS).slice(0, 10);
    setGame({
      players,
      scores: players.map(() => 0),
      deck,
      currentRound: 1,
      totalRounds: deck.length,
      difficulty,
    });
    setScreen("game");
  }

  const handleScore = useCallback((encoded: number) => {
    // encoded >= 0 means add point to that player
    // encoded < 0 means remove point (encoded = -(i+100), so i = -encoded - 100)
    setGame((prev) => {
      if (!prev) return prev;
      const scores = [...prev.scores];
      if (encoded >= 0) {
        scores[encoded] = (scores[encoded] ?? 0) + 1;
      } else {
        const i = -encoded - 100;
        scores[i] = Math.max(0, (scores[i] ?? 0) - 1);
      }
      return { ...prev, scores };
    });
  }, []);

  function handleNext() {
    setGame((prev) => {
      if (!prev) return prev;
      if (prev.currentRound >= prev.totalRounds) {
        setScreen("end");
        return prev;
      }
      return { ...prev, currentRound: prev.currentRound + 1 };
    });
  }

  function handlePlayAgain() {
    if (!game) return;
    const deck = shuffled(ATTACKS).slice(0, 10);
    setGame({ ...game, scores: game.players.map(() => 0), deck, currentRound: 1, totalRounds: deck.length });
    setScreen("game");
  }

  if (screen === "setup" || !game) {
    return <SetupScreen onStart={handleStart} />;
  }

  if (screen === "game") {
    return (
      <GameScreen
        players={game.players}
        scores={game.scores}
        deck={game.deck}
        currentRound={game.currentRound}
        totalRounds={game.totalRounds}
        difficulty={game.difficulty}
        onScore={handleScore}
        onNext={handleNext}
      />
    );
  }

  return (
    <EndScreen
      players={game.players}
      scores={game.scores}
      onPlayAgain={handlePlayAgain}
      onSetup={() => setScreen("setup")}
    />
  );
}
