pragma Singleton
import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null

    property PwObjectTracker sinkTracker: PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    readonly property int volume: audio ? Math.round(audio.volume * 100) : 0
    readonly property bool muted: audio ? audio.muted : false

    onVolumeChanged: Store.triggerVolumeOsd()
    onMutedChanged: Store.triggerVolumeOsd()

    function setVolume(percent) {
        if (!audio)
            return;

        audio.volume = Math.max(0, Math.min(1, percent / 100));
    }

    function toggleMute() {
        if (audio)
            audio.muted = !audio.muted;
    }
}
