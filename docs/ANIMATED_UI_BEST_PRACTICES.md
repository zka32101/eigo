# Animated UI Widgets - Best Practices Guide

## Overview

This guide provides best practices for using the animated UI widget system in the NPC game. It covers patterns, performance optimization, accessibility, and common use cases.

## Table of Contents

1. [Widget Selection](#widget-selection)
2. [Animation Patterns](#animation-patterns)
3. [Performance Optimization](#performance-optimization)
4. [Accessibility](#accessibility)
5. [Common Scenarios](#common-scenarios)
6. [Troubleshooting](#troubleshooting)

---

## Widget Selection

### Choosing the Right Widget

#### AnimatedDialogueBoxWidget
**Use when**:
- Displaying NPC dialogue with character-by-character reveal
- Need integrated sound effects
- Want default styling for dialogue

**Example**:
```dart
AnimatedDialogueBoxWidget(
  npcName: 'Aria',
  dialogueText: 'Welcome to my realm...',
  textAnimationDuration: Duration(milliseconds: 30),
  autoPlay: true,
)
```

#### AnimatedButtonWidget
**Use when**:
- Need interactive buttons with feedback
- Want consistent button styling
- Need enabled/disabled states

**Example**:
```dart
AnimatedButtonWidget(
  label: 'Accept Quest',
  onPressed: () => handleQuestAccept(),
  width: 200,
  height: 50,
)
```

#### AnimatedNPCCharacterWidget
**Use when**:
- Displaying NPC character with personality
- Need emotion-driven visual changes
- Want character appearance animations

**Example**:
```dart
AnimatedNPCCharacterWidget(
  npcId: 'aria_001',
  npcName: 'Aria',
  emotion: EmotionType.happy,
  isAnimating: true,
)
```

#### ParticleEffectWidget
**Use when**:
- Creating visual feedback for events
- Need configurable particle systems
- Want Canvas-based rendering

**Example**:
```dart
ParticleEffectWidget(
  effect: particleService.getSkillEffectByType('fire', position),
  onComplete: () => handleEffectComplete(),
)
```

#### NPCStatusIndicatorWidget
**Use when**:
- Displaying NPC status information
- Need animated progress bars
- Want mood/affection visualization

**Example**:
```dart
NPCStatusIndicatorWidget(
  npcName: 'Aria',
  affection: 75,
  affectionProgress: 0.75,
  mood: 'happy',
  level: 5,
)
```

#### ScreenTransitionWidget
**Use when**:
- Transitioning between screens
- Need smooth enter/exit animations
- Want multiple transition types

**Example**:
```dart
ScreenTransitionWidget(
  child: YourWidget(),
  transitionType: TransitionType.fadeSlide,
  isEntering: true,
)
```

---

## Animation Patterns

### Sequential Animations

Chain animations together for multi-step sequences:

```dart
class DialogueSequence {
  Future<void> playSequence() async {
    // Step 1: Character appear
    await characterWidget.playAnimation();
    
    // Step 2: Dialogue
    await dialogueWidget.playAnimation();
    
    // Step 3: Choices appear
    choicesVisible = true;
  }
}
```

### Concurrent Animations

Run multiple animations simultaneously:

```dart
Future.wait([
  characterWidget.playAnimation(),
  soundService.playBackgroundMusic('theme'),
  particleWidget.playAnimation(),
]);
```

### Staggered Animations

Offset animations for sequential visual effect:

```dart
for (int i = 0; i < choices.length; i++) {
  DialogueChoiceButtonWidget(
    choiceText: choices[i],
    delay: Duration(milliseconds: i * 100),
    onSelected: handleChoice,
  );
}
```

### Emotion Transitions

Smoothly transition between emotions:

```dart
class EmotionManager {
  void changeEmotion(EmotionType newEmotion) {
    // Emotion animation handles the transition
    _emotionController.forward();
    setState(() => currentEmotion = newEmotion);
  }
}
```

---

## Performance Optimization

### 1. Use `const` Constructors

```dart
// ✅ Good - const widget is only created once
const AnimatedButtonWidget(
  label: 'Button',
  onPressed: onPressed,
);

// ❌ Avoid - new widget created on each rebuild
AnimatedButtonWidget(
  label: 'Button',
  onPressed: onPressed,
);
```

### 2. Limit Particle Counts

```dart
// Mobile: 20-30 particles
ParticleEffect(
  type: EffectType.sparkle,
  particleCount: 20,  // Conservative for mobile
);

// Desktop: 50-100 particles
ParticleEffect(
  type: EffectType.sparkle,
  particleCount: 80,  // More for desktop
);
```

### 3. Cache Animations

```dart
// ✅ Cache expensive animations
class CachedAnimations {
  static final dialogueAppear = CurvedAnimation(
    parent: controller,
    curve: Curves.easeOut,
  );
}

// ❌ Avoid recreating on every build
CurvedAnimation(parent: controller, curve: Curves.easeOut);
```

### 4. Use AnimatedBuilder for Complex Scenes

```dart
// ✅ Only rebuilds when animation changes
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    // Only this builds on each animation frame
    return ComplexWidget();
  },
);

// ❌ Entire widget rebuilds
if (_controller.value > 0.5) {
  // This rebuilds everything
}
```

### 5. Profile Memory Usage

```dart
// Check memory with DevTools
// Target: <5 MB for full dialogue scene
// 10+ MB indicates potential issues
```

### 6. Clean Up Resources

```dart
@override
void dispose() {
  // Always dispose controllers
  _controller.dispose();
  _animationService.dispose();
  super.dispose();
}
```

---

## Accessibility

### 1. Text Size and Contrast

```dart
// ✅ Good - sufficient contrast
Text(
  'Dialogue',
  style: TextStyle(
    color: Colors.grey.shade800,  // Good contrast
    fontSize: 16,  // Readable size
  ),
);

// ❌ Avoid - poor contrast
Text(
  'Dialogue',
  style: TextStyle(
    color: Colors.grey.shade300,  // Too light
    fontSize: 12,  // Too small
  ),
);
```

### 2. Semantic Labels

```dart
// ✅ Good - provides context
Tooltip(
  message: 'Accept this quest',
  child: AnimatedButtonWidget(
    label: 'Accept',
    onPressed: onAccept,
  ),
);

// ❌ Avoid - no context
AnimatedButtonWidget(
  label: 'OK',
  onPressed: onAccept,
);
```

### 3. Animation Respects Motion Preferences

```dart
// ✅ Check for animation preferences
if (MediaQuery.of(context).disableAnimations) {
  // Skip animation or use instant transition
  return InstantWidget();
} else {
  return AnimatedWidget();
}
```

### 4. Keyboard Navigation

```dart
// ✅ Make buttons keyboard accessible
AnimatedButtonWidget(
  label: 'Submit',
  onPressed: onSubmit,
)
// Automatically supports keyboard focus in Flutter
```

---

## Common Scenarios

### Scenario 1: Complete Dialogue Flow

```dart
// See lib/examples/advanced_dialogue_scene_example.dart
// Shows:
// 1. Character appears with animation
// 2. Dialogue displays with text reveal
// 3. Choices appear with stagger
// 4. Selection triggers affection change
// 5. Screen transitions to next scene
```

### Scenario 2: Quest Accept Flow

```dart
void questAcceptFlow() {
  // 1. Show quest giver
  showCharacter(npc);
  
  // 2. Explain quest
  showDialogue('I need you to...');
  
  // 3. Show choices
  showChoices(['Accept', 'Decline']);
  
  // 4. Handle selection
  // 5. Show affection change
  // 6. Update NPC status
}
```

### Scenario 3: Skill Learning

```dart
void skillLearningFlow() {
  // 1. NPC changes emotion to excited
  npcWidget.updateEmotion(EmotionType.excited);
  
  // 2. Show dialogue about skill
  showDialogue('Let me teach you Fireball...');
  
  // 3. Show particle effects
  showEffect(EffectType.magic);
  
  // 4. Play sound effects
  soundService.playSkillSound('fire');
  
  // 5. Update affection
  showAffectionChange(+50);
}
```

### Scenario 4: Multiple NPCs

```dart
void showNPCGroup() {
  return Row(
    children: [
      AnimatedNPCCharacterWidget(
        npcId: 'aria',
        emotion: EmotionType.happy,
      ),
      AnimatedNPCCharacterWidget(
        npcId: 'luna',
        emotion: EmotionType.thinking,
      ),
    ],
  );
}
```

---

## Troubleshooting

### Issue: Animation Stutters

**Cause**: Too many concurrent animations or large particle counts

**Solution**:
```dart
// Reduce particle count
ParticleEffect(
  particleCount: 20,  // Was 100
);

// Stagger animations instead of concurrent
await animation1.complete();
await animation2.play();  // Play after first completes
```

### Issue: Memory Leaks

**Cause**: Controllers not disposed

**Solution**:
```dart
@override
void dispose() {
  _controller.dispose();  // Always dispose
  _animationService.dispose();
  super.dispose();
}
```

### Issue: Janky Text Reveal

**Cause**: Character duration too short

**Solution**:
```dart
// Increase duration if too fast
AnimatedDialogueBoxWidget(
  textAnimationDuration: Duration(milliseconds: 50),  // Was 20
);
```

### Issue: Affection Indicator Not Showing

**Cause**: Stack not properly positioned

**Solution**:
```dart
Stack(
  children: [
    YourContent(),
    Positioned(  // Must use Positioned in Stack
      top: 100,
      right: 50,
      child: AffectionChangeIndicatorWidget(...),
    ),
  ],
)
```

### Issue: Button Not Responding

**Cause**: Button disabled or event not called

**Solution**:
```dart
// Check enabled state
AnimatedButtonWidget(
  onPressed: () => print('Pressed'),
  enabled: true,  // Ensure enabled
);

// Verify callback is set
onPressed: () {
  setState(() => selectedChoice = index);
},
```

---

## Performance Benchmarks

| Operation | Target | Acceptable Range |
|-----------|--------|------------------|
| Dialogue appear | 300ms | 250-350ms |
| Text per character | 30ms | 20-50ms |
| Button click feedback | 200ms | 150-250ms |
| Screen transition | 500ms | 400-600ms |
| Particle effect | 60 FPS | 50-60 FPS |
| Full scene load | <1s | <1.2s |

---

## Widget Composition Patterns

### Pattern 1: Dialogue Scene

```dart
Column(
  children: [
    // Top: Character
    AnimatedNPCCharacterWidget(...),
    
    // Middle: Status
    NPCStatusIndicatorWidget(...),
    
    // Bottom: Dialogue and Choices
    AnimatedDialogueBoxWidget(...),
    if (showChoices)
      DialogueChoiceButtonWidget(...),
  ],
)
```

### Pattern 2: Overlay Effects

```dart
Stack(
  children: [
    // Main content
    MainContent(),
    
    // Overlay effects
    EffectOverlayWidget(...),
    
    // Floating indicators
    AffectionChangeIndicatorWidget(...),
  ],
)
```

### Pattern 3: Multi-Screen Flow

```dart
ScreenTransitionWidget(
  isEntering: isEntering,
  onTransitionComplete: () {
    if (!isEntering) {
      Navigator.pop(context);
    }
  },
  child: YourScreen(),
)
```

---

## Summary

Key Takeaways:
1. ✅ Choose widgets based on use case
2. ✅ Use animation patterns for consistency
3. ✅ Optimize for 60 FPS performance
4. ✅ Ensure accessibility compliance
5. ✅ Always dispose resources
6. ✅ Profile and monitor performance
7. ✅ Use the provided examples as templates

