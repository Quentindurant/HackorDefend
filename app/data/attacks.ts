export type Difficulty = "beginner" | "intermediate" | "expert";

export interface AttackCard {
  id: number;
  name: string;
  scenario: string;
  defense: string;
  explanation: string;
  category: string;
  hint: string;
}

export const ATTACKS: AttackCard[] = [
  {
    id: 1,
    name: "Phishing",
    scenario:
      "You receive an email from 'support@paypa1.com' asking you to verify your account by clicking a link. The email uses the company's official logo and looks completely legitimate.",
    defense: "Security Awareness Training",
    explanation:
      "Employees trained to inspect sender addresses, hover over links before clicking, and report suspicious emails are the strongest defense against phishing attacks.",
    category: "Social Engineering",
    hint: "The best defense is a human one — teach people to recognize the threat.",
  },
  {
    id: 2,
    name: "SQL Injection",
    scenario:
      "A hacker enters ' OR '1'='1'; DROP TABLE users; -- into your login form. They bypass authentication entirely and gain access to the full user database.",
    defense: "Input Validation & Prepared Statements",
    explanation:
      "Sanitizing all user inputs and using parameterized queries prevents malicious SQL from being executed. Never trust user input.",
    category: "Web Attack",
    hint: "The attack exploits raw user input — the defense happens at the code level, before the database.",
  },
  {
    id: 3,
    name: "Brute Force Attack",
    scenario:
      "An automated script tries 10 million password combinations per minute on your admin login page. After 2 hours, it successfully logs into the main admin account.",
    defense: "Two-Factor Authentication (2FA)",
    explanation:
      "Even if the correct password is discovered, 2FA requires a second verification step that the attacker cannot access remotely, blocking the login.",
    category: "Authentication",
    hint: "Even if the password is found, make sure a second barrier stops the attacker.",
  },
  {
    id: 4,
    name: "Ransomware",
    scenario:
      "An employee opens an attachment called 'Invoice_Final.pdf'. Within minutes, every file on the company network is encrypted. A popup demands $50,000 in Bitcoin.",
    defense: "Regular Backups + Antivirus",
    explanation:
      "Up-to-date offline backups allow full data recovery without paying the ransom. Antivirus and endpoint protection can detect and stop known ransomware before execution.",
    category: "Malware",
    hint: "If all your files are locked, you need a clean copy stored somewhere safe.",
  },
  {
    id: 5,
    name: "DDoS Attack",
    scenario:
      "Your e-commerce site receives 5 million requests per second from a botnet of 40,000 infected devices. The servers crash and the site is offline for 8 hours during a product launch.",
    defense: "Firewall + CDN / Rate Limiting",
    explanation:
      "A firewall filters malicious traffic patterns, a CDN distributes load across global servers, and rate limiting automatically blocks IPs sending too many requests.",
    category: "Network Attack",
    hint: "The attack is about overwhelming volume — think about filtering and distributing the load.",
  },
  {
    id: 6,
    name: "Social Engineering",
    scenario:
      "Someone calls your IT helpdesk claiming to be the CEO, stranded abroad without access to their account. They pressure the agent to reset their password immediately without verification.",
    defense: "Verification Protocol + Security Training",
    explanation:
      "Staff must never bypass identity verification due to urgency or authority. A strict callback protocol to a known number eliminates this manipulation technique.",
    category: "Social Engineering",
    hint: "Urgency and authority are manipulation tricks — a strict identity check process neutralizes them.",
  },
  {
    id: 7,
    name: "Man-in-the-Middle",
    scenario:
      "You connect to free airport Wi-Fi. An attacker on the same network intercepts your unencrypted connection to your company portal and captures your session token in real time.",
    defense: "VPN + HTTPS Enforcement",
    explanation:
      "A VPN encrypts all traffic between your device and the destination. HTTPS ensures data is encrypted in transit. Never use public Wi-Fi without a VPN for sensitive work.",
    category: "Network Attack",
    hint: "The attacker reads your data in transit — the defense is encrypting everything end-to-end.",
  },
  {
    id: 8,
    name: "Zero-Day Exploit",
    scenario:
      "Hackers discover a critical remote code execution flaw in a popular web framework before developers know about it. They scan the internet and compromise hundreds of servers within hours.",
    defense: "Intrusion Detection System (IDS) + Network Segmentation",
    explanation:
      "Since no patch exists yet, an IDS detects abnormal behavior patterns. Network segmentation limits lateral movement if one system is compromised.",
    category: "System",
    hint: "There's no patch yet, so you can't fix the flaw — you need to detect unusual activity and contain it.",
  },
  {
    id: 9,
    name: "Insider Threat",
    scenario:
      "A disgruntled employee about to be laid off copies the full customer database (names, emails, payment data) onto a personal USB drive the night before their last day.",
    defense: "Access Control (Least Privilege) + DLP Monitoring",
    explanation:
      "Least privilege ensures employees only access data required for their role. Data Loss Prevention (DLP) tools detect and block unauthorized bulk data transfers.",
    category: "Internal",
    hint: "The attacker already has legitimate access — limit what they can reach and monitor what they transfer.",
  },
  {
    id: 10,
    name: "Password Database Leak",
    scenario:
      "Your database is breached. The attacker exports 500,000 user passwords stored as plain MD5 hashes. Using rainbow tables, they crack 90% of them within a few hours.",
    defense: "Password Hashing (bcrypt / Argon2) + Salting",
    explanation:
      "Modern algorithms like bcrypt and Argon2 are intentionally slow to compute. Combined with a unique salt per user, rainbow table attacks become computationally infeasible.",
    category: "Authentication",
    hint: "The breach already happened — the defense was how passwords were stored before the attack.",
  },
  {
    id: 11,
    name: "Cross-Site Scripting (XSS)",
    scenario:
      "A hacker posts a comment with a hidden JavaScript snippet on your forum. Every user who loads the page silently sends their session cookie to the attacker's server.",
    defense: "Content Security Policy (CSP) + Input Sanitization",
    explanation:
      "Sanitizing all user-generated content prevents script injection. A CSP header instructs browsers to only run scripts from trusted, explicitly listed sources.",
    category: "Web Attack",
    hint: "The attacker injects code into your page — block untrusted scripts from running in users' browsers.",
  },
  {
    id: 12,
    name: "Credential Stuffing",
    scenario:
      "2 million email/password pairs from a previous breach are fed into an automated bot. It tests each combination on your platform. 12,000 accounts are successfully accessed.",
    defense: "2FA + Anomaly Detection",
    explanation:
      "2FA blocks logins even with valid credentials. Monitoring for unusual patterns (high velocity, multiple IPs) triggers automatic lockouts and security alerts.",
    category: "Authentication",
    hint: "The credentials are real but stolen — a second factor and suspicious activity detection stop the bot.",
  },
  {
    id: 13,
    name: "Malicious USB Drop",
    scenario:
      "USB drives labeled 'Staff Salaries Q4 2025' are left in your company's parking lot. A curious employee plugs one in. It silently installs a keylogger in the background.",
    defense: "Security Training + USB Port Restrictions",
    explanation:
      "Employees must never plug in unknown devices. IT can disable USB ports via group policy or physically block them on machines handling sensitive data.",
    category: "Physical",
    hint: "The attack relies on human curiosity — train people AND restrict the hardware entry point.",
  },
  {
    id: 14,
    name: "Unpatched Software",
    scenario:
      "Your servers run an outdated web framework with a publicly known critical vulnerability (CVE published 4 months ago). A hacker scans for it and compromises your system in minutes.",
    defense: "Patch Management Policy",
    explanation:
      "A structured patch management process ensures all software is updated promptly. Critical security patches should be applied within 24 to 72 hours of release.",
    category: "System",
    hint: "The fix already exists — the defense is making sure your team applies updates fast and consistently.",
  },
  {
    id: 15,
    name: "Clone Phishing Site",
    scenario:
      "Attackers build a pixel-perfect copy of your company's HR portal at 'hr-portal-mycompany.net' instead of 'hr.mycompany.com'. Dozens of employees log in and hand over their credentials.",
    defense: "Multi-Factor Authentication + Employee Training",
    explanation:
      "Even if credentials are captured on a fake site, MFA prevents the attacker from using them. Training employees to always verify the exact URL prevents the initial deception.",
    category: "Social Engineering",
    hint: "Even if users are fooled and type their password, make sure that alone isn't enough to log in.",
  },
];
