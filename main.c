#include <stdio.h>
#include <stdlib.h>
#include <ApplicationServices/ApplicationServices.h>

static CGFloat threshold = 4.0;

static CGEventRef eventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *userInfo) {
    CGPoint pt = CGEventGetLocation(event);
    if (pt.y < threshold) {
        // Clamp y in-place rather than blocking — blocking + CGWarpMouseCursorPosition causes
        // the HID layer to accumulate hardware deltas against y=0, making the cursor appear
        // stuck until the physical mouse moves far enough down to "pay back" the debt.
        pt.y = threshold;
        CGEventSetLocation(event, pt);
    }
    return event;
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        threshold = (CGFloat)atof(argv[1]);
    }

    const void *keys[]   = { kAXTrustedCheckOptionPrompt };
    const void *values[] = { kCFBooleanTrue };
    CFDictionaryRef options = CFDictionaryCreate(
        kCFAllocatorDefault, keys, values, 1,
        &kCFTypeDictionaryKeyCallBacks,
        &kCFTypeDictionaryValueCallBacks
    );
    bool trusted = AXIsProcessTrustedWithOptions(options);
    CFRelease(options);

    if (!trusted) {
        fprintf(stderr, "menubar-guard: Accessibility permission required.\n");
        fprintf(stderr, "Grant access in System Settings > Privacy & Security > Accessibility, then re-run.\n");
        return 1;
    }

    CGEventMask eventMask =
        (1 << kCGEventMouseMoved) |
        (1 << kCGEventLeftMouseDragged) |
        (1 << kCGEventRightMouseDragged) |
        (1 << kCGEventOtherMouseDragged);

    CFMachPortRef tap = CGEventTapCreate(
        kCGHIDEventTap,
        kCGHeadInsertEventTap,
        kCGEventTapOptionDefault,
        eventMask,
        eventCallback,
        NULL
    );

    if (!tap) {
        fprintf(stderr, "menubar-guard: Failed to create event tap.\n");
        fprintf(stderr, "Ensure Accessibility is enabled in System Settings, then re-run.\n");
        return 1;
    }

    CFRunLoopSourceRef source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopCommonModes);
    CGEventTapEnable(tap, true);

    printf("menubar-guard running (threshold: %dpx). Press Ctrl+C to stop.\n", (int)threshold);
    CFRunLoopRun();

    return 0;
}
