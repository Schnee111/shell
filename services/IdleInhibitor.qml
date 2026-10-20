pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Singleton {
    id: root

    property alias enabled: props.enabled
    readonly property alias enabledSince: props.enabledSince

    onEnabledChanged: {
        if (enabled)
            props.enabledSince = new Date();
    }

    PersistentProperties {
        id: props

        property bool enabled
        property date enabledSince

        reloadableId: "idleInhibitor"
    }

    IdleInhibitor {
        enabled: props.enabled
        window: PanelWindow {
            // Bind to a real screen so the surface is recreated after the
            // placeholder screen is replaced at startup or on monitor hotplug.
            // Without this the window can stay unmapped and the inhibitor is
            // never registered with the compositor.
            screen: Quickshell.screens[0] ?? null
            implicitWidth: 1
            implicitHeight: 1
            color: "transparent"
            mask: Region {}
        }
    }

    IpcHandler {
        function isEnabled(): bool {
            return props.enabled;
        }

        function toggle(): void {
            props.enabled = !props.enabled;
        }

        function enable(): void {
            props.enabled = true;
        }

        function disable(): void {
            props.enabled = false;
        }

        target: "idleInhibitor"
    }
}
