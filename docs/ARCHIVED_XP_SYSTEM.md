# Archived XP System (Gamification)

This document describes how the XP (Experience Points) system worked before it was removed on April 21, 2026.

## Overview
The XP system was designed to gamify the experience for couples by rewarding them for completing certain activities together. XP was shared between the couple and stored in the `couples` collection in Firestore.

## Data Model
XP-related fields in `CoupleModel`:
- `xp`: An integer representing the total XP earned by the couple.
- `completedBlueprintSections`: A list of section IDs for which XP was already awarded (to prevent double-granting for the same blueprint section).
- `questXpLastGrantedAt`: A map (`questId` -> `ISO-8601 Date String`) tracking the last time XP was granted for daily "quests" (memories, events, intimacy).

## XP Rewards
- **Blueprints:** +100 XP for completing a section (granted once per section per couple).
- **Memories:** +25 XP for adding a new memory (granted once per day).
- **Intimacy:** +20 XP for adding an intimacy log (granted once per day).
- **Events:** +15 XP for adding a new event (granted once per day).

## Logic
The logic was primarily handled in `user_stats_provider.dart` via the `grantQuestXpIfEligible` function.
1. It checked if the user was paired (had a `coupleId`).
2. It fetched the current `CoupleModel`.
3. it checked `isQuestCompletedToday` to ensure XP wasn't granted multiple times for the same activity on the same day (or for the same blueprint section).
4. If eligible, it called `FirebaseService.addCoupleXp` and `FirebaseService.setQuestXpGrantedAt`.

## UI Integration
- **Home Screen:** Displayed the total couple XP.
- **SnackBars:** Showed feedback when XP was earned (e.g., "System Updated: +100 XP acquired! 🚀").
