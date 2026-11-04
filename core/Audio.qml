pragma Singleton
import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null

    readonly property int volume: audio ? Math.round(audio.volume * 100) : 0
    readonly property bool muted: audio ? audio.muted : false

    function setVolume(percent) {
        if (!audio)
            return;
        let clamped = Math.max(0.0, Math.min(1.0, percent / 100.0));
        audio.volume = clamped;
    }
    function toggleMute() {
        if (!audio)
            return;
        audio.muted = !audio.muted;
    }

    property bool ready: false
    Component.onCompleted: ready = true

    onVolumeChanged: {
        if (ready) {
            Store.triggerVolumeOsd();
        }
    }
}
