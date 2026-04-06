import Cocoa

// MARK: - Threshold

let threshold: CGFloat = {
    if CommandLine.arguments.count > 1, let val = Double(CommandLine.arguments[1]) {
        return CGFloat(val)
    }
    return 4.0
}()

// MARK: - Accessibility check

let axOptions = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
guard AXIsProcessTrustedWithOptions(axOptions) else {
    fputs("menubar-guard: Accessibility permission required.\n", stderr)
    fputs("Grant access in System Settings > Privacy & Security > Accessibility, then re-run.\n", stderr)
    exit(1)
}

// MARK: - Event tap

let eventMask: CGEventMask =
    (1 << CGEventType.mouseMoved.rawValue) |
    (1 << CGEventType.leftMouseDragged.rawValue) |
    (1 << CGEventType.rightMouseDragged.rawValue) |
    (1 << CGEventType.otherMouseDragged.rawValue)

guard let tap = CGEvent.tapCreate(
    tap: .cghidEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: eventMask,
    callback: { _, _, event, _ -> Unmanaged<CGEvent>? in
        let pt = event.location
        if pt.y < threshold {
            // Clamp the event's position in-place rather than blocking it.
            // Blocking (return nil) + CGWarpMouseCursorPosition causes the HID layer to
            // accumulate hardware deltas against y=0, making the cursor appear stuck
            // until the physical mouse moves far enough down to "pay back" the debt.
            // Modifying the location and returning the event keeps the HID baseline
            // in sync with the clamped cursor position, preventing the freeze.
            event.location = CGPoint(x: pt.x, y: threshold)
        }
        return Unmanaged.passRetained(event)
    },
    userInfo: nil
) else {
    fputs("menubar-guard: Failed to create event tap.\n", stderr)
    fputs("Ensure Accessibility is enabled in System Settings, then re-run.\n", stderr)
    exit(1)
}

// MARK: - Run loop

let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
CGEvent.tapEnable(tap: tap, enable: true)

print("menubar-guard running (threshold: \(Int(threshold))px). Press Ctrl+C to stop.")
CFRunLoopRun()
