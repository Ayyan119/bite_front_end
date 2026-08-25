---
name: flutter-build-animations
description: Implement smooth, performant Flutter animations using implicit widgets, explicit controllers, Hero transitions, physics simulations, and Rive/Lottie assets. Use when adding micro-interactions, page transitions, loading spinners, state transitions, or complex canvas animations in Flutter.
---

# Flutter Animation Guidelines & Best Practices

Use this skill when designing, implementing, or optimizing animations in Flutter applications.

## 1. Choosing the Right Animation Pattern

Use the decision matrix below to select the appropriate animation technique:

| Requirement | Recommended Approach | Key Classes / Widgets |
| :--- | :--- | :--- |
| **Simple state change** (e.g. color, size, fade on toggle) | **Implicit Animations** | `AnimatedContainer`, `AnimatedOpacity`, `AnimatedPadding`, `AnimatedSwitcher`, `TweenAnimationBuilder` |
| **Controlled timing, sequence, or repeat** (play, pause, reverse, loop) | **Explicit Animations** | `AnimationController`, `CurvedAnimation`, `Tween`, `AnimatedBuilder` |
| **Shared element transition between routes** | **Hero Animations** | `Hero` widget with matching `tag` |
| **Touch-driven physics / gesture spring-back** | **Physics-based Animations** | `SpringSimulation`, `GravitySimulation`, `GestureDetector` |
| **Complex vector or interactive illustrations** | **Lottie or Rive** | `package:lottie`, `package:rive` |
| **High performance custom canvas drawing** | **CustomPainter + Animation** | `CustomPainter`, `AnimatedBuilder`, `RepaintBoundary` |

---

## 2. Implicit Animations (Zero-Boilerplate)

Use implicit animations for simple, state-driven transitions without managing controllers or tickers.

### `AnimatedContainer` Example
```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOutCubic,
  width: isExpanded ? 200 : 100,
  height: isExpanded ? 200 : 100,
  decoration: BoxDecoration(
    color: isExpanded ? Colors.indigo : Colors.blueAccent,
    borderRadius: BorderRadius.circular(isExpanded ? 16 : 8),
  ),
  child: const Center(child: Icon(Icons.star, color: Colors.white)),
);
```

### `AnimatedSwitcher` for Content Swapping
```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 250),
  transitionBuilder: (Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(scale: animation, child: child),
    );
  },
  child: Text(
    '$count',
    key: ValueKey<int>(count), // ValueKey triggers switch
    style: Theme.of(context).textTheme.headlineMedium,
  ),
);
```

---

## 3. Explicit Animations (Controller-Based)

Use explicit animations when you need precise control (start, stop, repeat, reverse) or staggered timing sequences.

### Controller Setup Pattern
```dart
class PulseButton extends StatefulWidget {
  const PulseButton({super.key});

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose controller to prevent memory leaks!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pass static child to AnimatedBuilder so it is NOT rebuilt every frame
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Tap Me'),
      ),
    );
  }
}
```

---

## 4. Hero Screen Transitions

Pass matching `tag` strings across routes for seamless element morphing:

```dart
// Screen A (Source)
Hero(
  tag: 'product-image-${product.id}',
  child: Image.network(product.imageUrl),
)

// Screen B (Destination)
Hero(
  tag: 'product-image-${product.id}',
  child: Image.network(product.imageUrl),
)
```

---

## 5. Performance Optimization Rules

1. **Pass static subtrees to `child` parameter**: In `AnimatedBuilder` or `TweenAnimationBuilder`, place heavy static widgets in the `child` argument so Flutter reuses the element without rebuilding it on every frame.
2. **Use `RepaintBoundary` for isolated repaints**: Wrap animating components (especially `CustomPainter` or complex widgets) in `RepaintBoundary` to prevent redrawing the entire screen layer.
3. **Always dispose `AnimationController`**: Call `_controller.dispose()` in `State.dispose()` to avoid ticker leaks.
4. **Use `const` constructors**: Declare static widgets with `const` to allow compiler optimization and memory sharing.
5. **Prefer standard curves**: Use built-in curves (`Curves.easeInOutCubic`, `Curves.fastOutSlowIn`) for natural-feeling physics.
