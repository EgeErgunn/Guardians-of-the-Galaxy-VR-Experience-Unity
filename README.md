# 🚀 Guardians of the Galaxy: The VR Experience

A first-person cinematic Virtual Reality narrative experience built in **Unity**, placing the player directly into the pilot's seat of the iconic **Milano** spacecraft from Marvel's *Guardians of the Galaxy*.

Developed as a term project for **MAVA 357**, focusing on interactive spatial design, diegetic UI/audio cues, zero-gravity locomotion, and cinematic VR storytelling[cite: 2, 3].

---

## 🎬 Gameplay Walkthrough

Watch the full VR experience walkthrough on YouTube:

[![Guardians of the Galaxy VR Experience Full Video](https://img.youtube.com/vi/PxoP25L8n8o/0.jpg)](https://youtu.be/PxoP25L8n8o)

> 🔗 **Video Link:** [https://youtu.be/PxoP25L8n8o](https://youtu.be/PxoP25L8n8o)

---

## 🎮 Narrative & Scene Breakdown

The experience is structured across 3 continuous narrative acts designed with diegetic guidance to preserve immersion[cite: 2, 3]:

### Act 1: Milano Cockpit Interior (The Awakening)
* **Diegetic Call to Action:** The player spawns in total cockpit darkness with a single glowing Walkman cassette player ahead[cite: 3, 4].
* **Cinematic Launch:** Interacting with the Walkman plays *"Come and Get Your Love"* by Redbone, triggering the sequential illumination of cockpit lights, system boot sequences, and engine ignition[cite: 3, 4].
* **Emergency Briefing:** The ship halts as power cuts out and red emergency strobe lights pulse[cite: 3, 4]. Rocket Raccoon contacts the player over the radio, briefing them on an exterior breach and unlocking the airlock[cite: 3, 4].

### Act 2: Open Space & Exterior Hull Combat
* **Zero-G Locomotion:** The player transitions through the airlock into open space equipped with thrusters[cite: 3, 4].
* **Combat Mechanics:** The player dual-wields Star-Lord's element blasters to clear 5 parasite leeches attached across the Milano's outer hull[cite: 2, 3, 4].
* **Diegetic HUD & Guidance:** High-contrast emission colors on targets and dynamic spatial audio provide orientation without immersion-breaking waypoints[cite: 3]. Rocket confirms mission success once all 5 targets are eliminated, prompting re-entry[cite: 3, 4].

### Act 3: Milano Cockpit Return (Escape)
* **Command Sequence:** Upon re-entering, the central pilot seat pulses with an emission glow[cite: 3].
* **Interactive Controls:** Sitting locks the player into position, prompting a physics-driven lever pull[cite: 3, 4].
* **Cinematic Climax:** Pushing the primary acceleration lever spools the engines, initiating ship escape before cutting to the title card sequence[cite: 3, 4].

---

## 🛠️ Technical Implementation & Asset Pipeline

* **Engine:** Unity (XR Interaction Toolkit / OpenXR)
* **3D Modeling & Environment:** 
  * Custom cockpit interior, control panels, pilot seats, and interaction levers modeled in **Blender**[cite: 4].
  * Detailed spaceship exterior and Star-Lord dual blaster models[cite: 4].
* **Lighting & Atmosphere:**
  * Dual directional lighting setups (Pink/Purple nebula theme with dynamic intensity)[cite: 4].
  * Synchronized emergency red strobe lighting driven via C# coroutines[cite: 3, 4].
* **Audio Engineering:**
  * Spatial 3D directional audio for cockpit ambience, thrusters, and weapons[cite: 4].
  * Voiceover processing for Rocket Raccoon radio transmissions[cite: 3, 4].
* **VFX:**
  * Custom particle systems for leech disintegrations, blaster muzzle flashes, impact sparks, and skybox nebula rotation[cite: 4].

---

## 📁 Repository Structure

```text
mava357_finalproject/
├── Assets/
│   ├── Scripts/            # Core interactions, levers, weapon logic, audio managers
│   ├── Models/             # Blender FBX models (Milano Cockpit, Pilot Chair, Levers)
│   ├── Prefabs/            # XR Rig, Blasters, Interactive Objects, FX
│   ├── Audio/              # Radio comms, SFX, licensed soundtrack
│   └── Scenes/             # MilanoCockpit_Main.unity
├── Packages/
└── ProjectSettings/
