# Hack or Defend — Concept Document

---

## 1. Game Overview

**Game name:** Hack or Defend
**Topic:** Cybersecurity
**Format:** Card game with a digital app (multiplayer)
**Players:** 2 to 4
**Duration:** around 15 to 30 minutes
**Target audience:** Bachelor students in digital, or anyone who wants to learn about cybersecurity

---

## 2. Educational Objective

Cybersecurity is a very important topic in the digital world but a lot of students find it complicated or boring. The goal of Hack or Defend is to make it more fun and easier to understand.

With this game, players will learn to:
- Recognize the most common types of cyber attacks (phishing, ransomware, SQL injection, DDoS...)
- Know which defense to use for each attack
- Understand why the defense works, not just what it is
- Talk about cybersecurity in English

---

## 3. How the Game Works

The game is based on **attack cards**. Each card describes a real cyber attack situation.

### A turn looks like this:

1. A card is shown to all players. It has the **name of the attack**, a **scenario** (a short story that explains the attack), and the **category** (for example: Social Engineering, Web Attack...)
2. Players talk together and each one says which defense they think is the right answer
3. The answer is revealed with the **correct defense** and an **explanation**
4. Players who had the right answer get **+1 point**
5. Next card

### Score

Each correct answer gives 1 point. The player with the most points at the end wins. If two players have the same score, the one who was faster in Expert mode wins.

---

## 4. Difficulty Levels

We made 3 difficulty levels so the game can work for different players:

| Level | Timer | Hints | What changes |
|---|---|---|---|
| 🟢 Beginner | No | Yes | A hint is shown to help players think |
| 🟡 Intermediate | No | No | No hints, players use only the scenario |
| 🔴 Expert | 20 seconds | No | Players have only 20 seconds to answer |

This is useful because some players already know a bit about cybersecurity and others are complete beginners. With these 3 levels, everyone can play at their own pace.

---

## 5. The Cards

There are **15 attack cards** in the game. They cover 7 different categories:

| Category | Attacks |
|---|---|
| Social Engineering | Phishing, Social Engineering, Clone Phishing Site, Malicious USB Drop |
| Web Attack | SQL Injection, Cross-Site Scripting (XSS) |
| Authentication | Brute Force Attack, Password Database Leak, Credential Stuffing |
| Malware | Ransomware |
| Network Attack | DDoS Attack, Man-in-the-Middle |
| System | Zero-Day Exploit, Unpatched Software |
| Internal Threat | Insider Threat |

Each card has:
- The **attack name**
- A **scenario**: a short realistic story about the attack (for example: *"You receive an email from 'support@paypa1.com' asking you to click a link..."*)
- The **correct defense** (for example: *"Security Awareness Training"*)
- An **explanation** of why the defense works
- A **hint** (only in Beginner mode) to help players find the answer

---

## 6. Why We Made These Choices

### Why cards and not a classic quiz?
We wanted players to discuss together and not just click on an answer alone. With cards, everyone talks, argues and learns from each other. It's more fun and you remember better when you have to explain your choice.

### Why scenarios and not just definitions?
If we just write "Phishing = fake email", it's easy to forget. But if we write a story like "a hacker sends you a fake email that looks exactly like your bank", it's more realistic and easier to remember. Players can imagine it happening to them.

### Why show the explanation after the answer?
Because just knowing the correct defense is not enough. We want players to understand the logic behind it. For example, knowing that 2FA blocks a brute force attack makes sense only if you understand why a second step stops the hacker even if they have the password.

### Why 3 difficulty levels?
Because a class is never 100% beginner or 100% expert. With 3 levels, the teacher can choose what fits the group, or students can challenge themselves by going from Beginner to Expert.

---

## 7. The Digital App

We also made a **web application** for the game. It is built with Next.js and can be used online.

The app is not a replacement for the game. It's more like a **shared screen** that all players look at together. It shows the attack cards, manages the scores, and runs the countdown timer in Expert mode.

The good thing is that you don't need to print anything. You just open the app on a computer or tablet and you can play directly. The app also shows colors to make the game clearer: red for attacks, green for defenses.

---

## 8. Why Cybersecurity?

We chose cybersecurity because it's a topic that concerns everyone in the digital sector, no matter what your job is:
- A **developer** needs to know about SQL injection and XSS to write safe code
- A **designer** needs to understand phishing to design interfaces that don't mislead users
- A **project manager** needs to know about ransomware to understand the risks for a company
- A **marketer** who works with customer data needs to understand what a data breach is

Also, cybersecurity is very present in job offers in the digital field. Even if you are not a security expert, knowing the basics is a real advantage.

---

*Document made for the English Game 2026 — Rattrapage*
*MyDigitalSchool*
