design.md — Patterns Mobile App

Overview

Patterns is an OCD journaling and tracking app focused on helping users understand intrusive thoughts, compulsions, and emotional patterns over time.

The mobile experience should feel:

* Calm
* Private
* Minimal
* Intentional

This is not a dashboard-heavy app. It is a reflection-first product.

⸻

Core Principles

1. Mobile ≠ Desktop Shrink

Do not replicate desktop layouts (sidebars, dense data, multi-column UI).

2. Reduce Cognitive Load

Users may already be distressed. UI must:

* minimize decisions
* reduce clutter
* guide actions clearly

3. Focus on Daily Flow

Primary loop:
Open app → See Today → Act (Write / Track) → Reflect → Return later for Insights

4. No Over-Branding

Avoid:

* logo on every screen
* app name at the top of all views

Brand should be subtle, not loud.

⸻

Navigation Structure

Bottom Tab Bar (Floating)

4 elements max:
Journal | Track | + | Insights

Behavior

* Floating pill style
* Slight blur / translucent background
* Rounded corners
* Center + is primary action
* Active tab highlighted (yellow accent)

+ Button Action Sheet

Opens modal:
What do you want to add?

- Journal Entry
- OCD Event

Screen Architecture

⸻

1. Welcome Screen

Goal

Create trust and calm onboarding.

Layout

Top:

* Abstract visual / minimal illustration

Center:
Understand your patterns.
One entry at a time.

Subtext:
Track intrusive thoughts, compulsions, distress,
and daily reflections in a calm private space.

Bottom:

* Primary: Start journaling
* Secondary: Import existing data

Notes

* No heavy branding
* No loud colors
* No clutter

⸻

2. Home (Today Screen)

Goal

Anchor the app around today.

Layout

Top-left:
Today
<date>

Top-right:

* settings icon / profile circle

⸻

Main Card
How are you feeling right now?
[ Distress Slider: 0 — 10 ]

⸻

Primary Actions

Two large cards:

* Write Journal
* Track OCD Event

⸻

Recent Activity

* Last journal entry
* Last OCD event
* Streak / consistency indicator

⸻

Notes

* This replaces a traditional dashboard
* Must feel lightweight and welcoming

⸻

3. Journal Screen

Goal

Make journaling effortless and distraction-free.

Layout

Top:
Journal

Right:

* search icon
* calendar icon

⸻

Content

* Horizontal date selector (optional)
* “Today” entry card
* List of recent entries

⸻

Entry Editor

Full-screen experience:

* large text area
* minimal toolbar
* autosave (subtle indicator)

Top:
Date

⸻

Notes

Avoid:

* sidebars
* metadata-heavy UI
* cluttered formatting tools

⸻

4. OCD Tracker Screen

Goal

Fast, low-friction event logging.

Layout

Top:
Track

Filters:

* All
* Obsessions
* Compulsions

⸻

Event List

Each card:

* Type (chip)
* Title
* Distress level
* Response/strategy preview
* Timestamp

⸻

Add Event

Triggered via + button → full-screen sheet

Fields:

1. Type (toggle)
    * Obsession
    * Compulsion
2. What happened?
3. What did you do?
4. Strategy / Response
5. Distress (slider)
6. Save button

⸻

Notes

* Must feel quick
* Avoid form fatigue
* Distress slider should be visually strong

⸻

5. Insights Screen

Goal

Help users understand patterns without overwhelming them.

Layout

Top:
Insights

Time range selector:

* 7D / 30D / 90D / Year

⸻

Summary Cards (Grid)

* Journal entries
* OCD events
* Average distress
* Most common trigger

⸻

Charts (Stacked)

1. Distress trend
2. Journaling consistency
3. Obsession vs compulsion ratio
4. Trigger patterns

⸻

Notes

Avoid:

* dense desktop charts
* full-year grids as default
* too many visualizations at once

⸻

6. Settings

Placement

NOT in tab bar.

Accessible via:

* top-right icon on Home
* or overflow menu

⸻

Contents

* Theme (Dark default)
* Export data
* Import data
* Backup options (future)

⸻

Visual Design System

⸻

Colors

* Background: deep charcoal (not pure black)
* Cards: slightly lighter charcoal
* Borders: low-opacity gray
* Accent: warm yellow
* High distress: muted red
* Low distress: soft green

⸻

Typography

* Large, readable headers
* Generous line spacing for journal text
* Minimal use of all-caps
* Soft hierarchy

⸻

Components

Cards

* Rounded corners
* Subtle border
* Light elevation or shadow

Buttons

* Primary: yellow accent
* Secondary: outlined / subtle fill

Inputs

* Clean
* Spacious
* Focus state highlighted

⸻

Interaction Patterns

* Use bottom sheets instead of popups
* Prefer full-screen flows for writing
* Animate transitions subtly
* Avoid sudden UI jumps

⸻

Key UX Decisions

* No settings tab
* No logo/name on every screen
* No dashboard-first design
* No cluttered analytics
* No heavy forms

⸻

Core Experience Summary

This app should feel like:

* a private notebook
* a calm reflection tool
* a safe space for tracking mental patterns

Not like:

* a productivity dashboard
* a data-heavy analytics tool
* a SaaS product
