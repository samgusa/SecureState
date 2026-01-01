# SecureState

SecureState is a privacy-first iOS app that provides real-time, contextual security awareness through a clear and approachable scoring system.

The app answers one core question:

**“Is right now a safe moment for sensitive activities on my device?”**

Instead of overwhelming users with technical jargon or static checklists, SecureState combines device configuration, environmental context, and user confirmation into a single, easy-to-understand security score with plain-language guidance.

---

## What SecureState Does

SecureState continuously evaluates factors that influence everyday digital safety and presents them as a 100-point security score. The score updates as conditions change, helping users understand *when* it’s safe to perform sensitive actions like logging into accounts, accessing financial apps, or handling private information.

The app is designed to be:
- Educational without being overwhelming
- Privacy-focused and fully on-device
- Honest about what can and cannot be detected automatically

SecureState does **not** replace antivirus software and does **not** perform real-time threat monitoring.

---

## Core Design Philosophy

- **Clarity over complexity** – security guidance should be understandable by non-experts
- **User control** – users can confirm or override automatic detections
- **Privacy first** – no personal data collection, no external transmission
- **Context matters** – security depends on both device configuration and environment

All assessments and calculations are performed locally on the device.

---

## Scoring System Overview (100 Points)

SecureState uses a dual-domain scoring model visualized as two connected half-circles:

### Device Security (55 points max)
“Is my device configured safely for sensitive activities?”

Examples of checks:
- iOS version currency
- Device lock & biometric protections
- Passcode strength (user-confirmed)
- Screen recording / mirroring detection
- VPN usage (hybrid detection + user confirmation)

### Situational Awareness (45 points max)
“Is my current environment safe for sensitive activities?”

This domain focuses on **context**, not just configuration.

---

## Hybrid Detection Model

SecureState uses a **hybrid detection approach**:

- Automatic detection where reliable
- User confirmation when context cannot be safely inferred
- Clear explanations for every score contribution

This avoids invasive scanning while still providing meaningful guidance.

---

## Interactive & Educational Features

- Real-time security score with contextual messaging
- Environmental risk matrix showing “what if” scenarios
- Interactive modeling (e.g., switching networks or locations)
- Plain-language recommendations tied directly to score changes
- Achievement-style feedback to encourage better security habits

---

## Privacy & Data Handling

- No personal data collection
- No network scanning beyond basic connection context
- No data sent off-device
- No tracking or analytics
- All processing happens locally

Users remain in full control of what is detected and what is confirmed manually.

---

## Technical Overview

- **Platform:** iOS
- **Language:** Swift
- **UI:** SwiftUI
- **Architecture:** Modular, state-driven design
- **Detection Style:** Hybrid (automatic + user confirmation)
- **Persistence:** On-device only (Keychain used for sensitive values)

---

## Limitations & Honest Boundaries

- Client-side apps cannot fully guarantee secrecy against determined attackers
- Environmental context relies partly on user input for accuracy
- The app focuses on *awareness*, not intrusion detection or malware scanning
- Designed for everyday users, not enterprise threat modeling

These limitations are intentionally communicated to users within the app.

---

## What I’d Improve Next

With additional time or a backend component:
- Optional backend proxy for sensitive API interactions
- Expanded automated testing around scoring logic
- Deeper visualization of long-term security trends
- More granular explanations tailored to user experience level

---

## Disclaimer

SecureState is an educational security awareness app.  
It does not replace antivirus software, mobile device management tools, or professional security solutions.

--- 

## [Terms of Use:](https://www.apple.com/legal/internet-services/itunes/dev/stdeula/)



---

## [Privacy Policy:](https://samgusa.github.io/SecureState-privacy-policy/)
