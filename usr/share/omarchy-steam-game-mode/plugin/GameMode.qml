import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.gamemode"

  property bool isInstalled: false

  Process {
    id: checkProc
    command: ["omarchy-pkg-present", "gamescope"]
    running: true
    onExited: function(exitCode) {
      root.isInstalled = (exitCode === 0)
    }
  }

  visible: isInstalled
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰊴"
    slotSize: Style.bar.statusSlot
    fontSize: Style.font.caption
    tooltipText: "Enter Game Mode"
    onPressed: function() {
      root.bar.run("omarchy-launch-floating-terminal-with-presentation omarchy-steamos-session-interactive")
    }
  }
}
