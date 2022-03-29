// in ~/.local/share/plasma/plasmoids
// plasmoidviewer --applet ipaddr/plasmoid/
// kpackagetool5 -t Plasma/Applet --install ipaddr/plasmoid
// kbuildsycoca5
import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    anchors.centerIn: parent
    property string ip
    property string ifconfig
    Plasmoid.hideOnWindowDeactivate: false
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    onIpChanged: {
        get_all()
    }
    Component.onCompleted: {
        get_all()
    }
    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(sourceName, exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName)
        }
        function exec(cmd) {
            if (cmd) {
                connectSource(cmd)
            }
        }
        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }
    Connections {
        target: executable
        onExited: {
            if (cmd == "ip -brief addr show scope global | grep UP | grep -Eo '([0-9]+\.){3}[0-9]+/[0-9]+'") {
                var ip = stdout.trim().split(' ').filter(function () {return true}).join('\n') //filter: remove empty elements
                root.ip = ip
                //for(var i = 0; i < ips.length; i++) {
                //    root.code = root.code + ips[i] + '+++';
                //}
            } else if (cmd == "ip -brief addr show scope global | grep UP") {
                root.ifconfig = stdout.trim()
            }
        }
    }
    Plasmoid.compactRepresentation: Item {
        PlasmaComponents.Label {
            text: root.ip
            height: parent.height
            width: parent.width
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
            fontSizeMode: Text.Fit
            //font.pointSize: height
            font.pointSize: width
        }
         //PlasmaCore.IconItem {
         //    //source: "network-connect"
         //    anchors.fill: parent
         //    Rectangle {
         //        //width: parent.width / 3.5
         //        //height: parent.height / 3.5
         //        anchors.right: parent.right
         //        anchors.bottom: parent.bottom
         //        color: PlasmaCore.ColorScope.backgroundColor

         //    }
         //}

        MouseArea {
            //width: parent.width
            //height: parent.width
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                plasmoid.expanded = !plasmoid.expanded
            }
        }
    }
    Plasmoid.fullRepresentation: Item {
        Layout.preferredWidth: childrenRect.width * units.devicePixelRatio
        Layout.preferredHeight: childrenRect.height * units.devicePixelRatio
        Layout.maximumWidth: 1000
        Layout.fillHeight: true
        Layout.fillWidth: true
        PlasmaComponents.Label {
            id: label_full
            text: root.ifconfig
            //height: parent.height
            //width: parent.width
            //width: 1000
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignBottom
            fontSizeMode: Text.Fit
            font.pointSize: height
        }
        
    }
    function get_all() {
        get_ip()
        get_ifconfig()
    }
    function get_ip() {
        executable.exec("ip -brief addr show scope global | grep UP | grep -Eo '([0-9]+\.){3}[0-9]+/[0-9]+'")
    }
    function get_ifconfig() {
        executable.exec("ip -brief addr show scope global | grep UP")
    }

    PlasmaNM.NetworkStatus {
        id: networkStatus

        onActiveConnectionsChanged: {
            get_all()
        }
    }

    //// When signals are not triggered (standalone anyconnect, manual addition, namespaces...)
    //Timer {
    //    id: timer
    //    running: true
    //    repeat: true
    //    interval: 360000 //360 secs
    //    onTriggered: {
    //        get_all()
    //    }
    //}
}

