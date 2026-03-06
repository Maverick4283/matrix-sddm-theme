// =============================================================================
// LOGIN BOX COMPONENT - Matrix Trilogy SDDM Theme
// =============================================================================

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import SddmComponents 2.0

Item {
    id: root
    
    // =========================================================================
    // PROPERTIES
    // =========================================================================
    
    property color matrixColor: "#00FF41"
    property color borderColor: "#00FF41"
    property color errorColor: "#FF0000"
    property bool showAvatar: true
    property int boxWidth: 420
    property int boxHeight: 550
    property real backgroundOpacity: 0.70
    
    property int selectedUserIndex: 0
    property int selectedSessionIndex: 0
    property string currentUsername: ""
    property string currentSessionName: ""
    property string errorMessage: ""
    property bool showError: false
    property bool isLoggingIn: false
    property var passwordMask: []
    
    // IMPORTANT: Intro state from Main.qml
    property bool introComplete: true
    
    property var katakanaChars: [
        "ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ",
        "サ", "シ", "ス", "セ", "ソ", "タ", "チ", "ツ", "テ", "ト"
    ]
    
    width: boxWidth
    height: boxHeight
    
    signal loginRequest(string username, string password, int sessionIndex)
    
    // =========================================================================
    // PUBLIC FUNCTIONS
    // =========================================================================
    
    // Called by Main.qml when intro completes
    function takeFocus() {
        passwordInput.forceActiveFocus()
    }
    
    // =========================================================================
    // FONT
    // =========================================================================
    
    FontLoader {
        id: monoFont
        source: "../fonts/JetBrainsMono-Regular.ttf"
    }
    
    // =========================================================================
    // HELPER - Get data from model with multiple fallback methods
    // =========================================================================
    
    function getUserNameAtIndex(idx) {
        if (typeof userModel === 'undefined' || !userModel) {
            return "User"
        }
        
        // Method 1: Try data() with different roles
        var roles = [Qt.DisplayRole, Qt.UserRole, 0, 257, 258]
        for (var i = 0; i < roles.length; i++) {
            try {
                var data = userModel.data(userModel.index(idx, 0), roles[i])
                if (data && data.toString().length > 0) {
                    return data.toString()
                }
            } catch (e) {
                // Ignore errors, try next method
            }
        }
        return "User"
    }
    
    function parseSessionPath(path) {
        // If path contains "/" it's a file path, extract filename
        if (path.indexOf("/") !== -1) {
            // Get filename from path: /usr/share/wayland-sessions/plasma.desktop -> plasma.desktop
            var parts = path.split("/")
            var filename = parts[parts.length - 1]
            
            // Remove .desktop extension: plasma.desktop -> plasma
            if (filename.indexOf(".desktop") !== -1) {
                filename = filename.replace(".desktop", "")
            }
            
            // Beautify common session names
            if (filename === "plasma") {
                return "Plasma (Wayland)"
            } else if (filename === "plasmax11") {
                return "Plasma (X11)"
            } else if (filename === "gnome") {
                return "GNOME"
            } else if (filename === "gnome-xorg") {
                return "GNOME (X11)"
            } else {
                // Capitalize first letter
                return filename.charAt(0).toUpperCase() + filename.slice(1)
            }
        }
        // If no path, return as-is
        return path
    }
    
    function getSessionNameAtIndex(idx) {
        if (typeof sessionModel === 'undefined' || !sessionModel) {
            return "Plasma"
        }
        
        // Method 1: Try data() with different roles
        var roles = [Qt.DisplayRole, Qt.UserRole, 0, 257, 258]
        for (var i = 0; i < roles.length; i++) {
            try {
                var data = sessionModel.data(sessionModel.index(idx, 0), roles[i])
                if (data && data.toString().length > 0) {
                    var rawData = data.toString()
                    
                    // Parse if it's a path
                    var parsed = parseSessionPath(rawData)
                    return parsed
                }
            } catch (e) {
                // Ignore errors, try next method
            }
        }
        
        return "Plasma"
    }
    
    // =========================================================================
    // FUNCTIONS
    // =========================================================================
    
    function getRandomKatakana() {
        return katakanaChars[Math.floor(Math.random() * katakanaChars.length)]
    }
    
    function getPasswordDisplay() {
        return passwordMask.join(" ")
    }
    
    function showErrorMessage(msg) {
        errorMessage = msg
        showError = true
        errorHideTimer.restart()
        shakeAnim.start()        // Shake for LoginBox
        errorShakeAnim.start()   // Shake for popup window
    }
    
    function attemptLogin() {
        
        if (passwordInput.text.length === 0) {
            showErrorMessage("Password required")
            return
        }
        
        if (!currentUsername || currentUsername === "User") {
            showErrorMessage("Please select a user")
            return
        }
        
        isLoggingIn = true
        loginRequest(currentUsername, passwordInput.text, selectedSessionIndex)
        resetTimer.start()
    }
    
    // =========================================================================
    // TEMPORARY ITEM - Read session name properly from model delegate
    // =========================================================================
    
    Item {
        id: sessionNameReader
        visible: false
        property var sessionNames: ({})

        function getNameAt(idx) {
            return sessionNames[idx] || ""
        }

        Instantiator {
            model: typeof sessionModel !== 'undefined' ? sessionModel : null

            delegate: Item {
                Component.onCompleted: {
                    sessionNameReader.sessionNames[index] = model.name || "Session"
                }
            }
        }
    }
    
    // =========================================================================
    // INITIALIZATION WITH TIMER (wait for models to be ready)
    // =========================================================================
    
    Timer {
        id: initTimer
        interval: 100
        running: false
        repeat: false
        
        onTriggered: {
            
            // Get initial user
            if (typeof userModel !== 'undefined' && userModel && userModel.count > 0) {
                
                selectedUserIndex = userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                currentUsername = getUserNameAtIndex(selectedUserIndex)
                
            } else {
                currentUsername = "User"
            }
            
            // Get initial session - try multiple methods
            if (typeof sessionModel !== 'undefined' && sessionModel && sessionModel.count > 0) {
                
                selectedSessionIndex = sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
                
                // Wait a bit for Instantiator to read the name
                sessionInitTimer.start()
            } else {
                currentSessionName = "Plasma"
            }
            
            // IMPORTANT: Only take focus if intro is already complete
            if (root.introComplete) {
                passwordInput.forceActiveFocus()
            } else {
            }
        }
    }
    
    Timer {
        id: sessionInitTimer
        interval: 50
        running: false
        repeat: false
        
        onTriggered: {
            var name = sessionNameReader.getNameAt(selectedSessionIndex)
            currentSessionName = name.length > 0 ? name : "Unknown"
        }
    }
    
    Component.onCompleted: {
        initTimer.start()
    }
    
    Timer {
        id: errorHideTimer
        interval: 3000
        onTriggered: showError = false
    }
    
    Timer {
        id: resetTimer
        interval: 2000
        onTriggered: {
            isLoggingIn = false
            passwordInput.text = ""
            passwordMask = []
        }
    }
    
    // =========================================================================
    // BACKGROUND
    // =========================================================================
    
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.backgroundOpacity
        radius: 4
    }
    
    // =========================================================================
    // BORDER WITH GLOW
    // =========================================================================
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: root.matrixColor
        border.width: 2
        radius: 4
        
        layer.enabled: true
        layer.effect: Glow {
            radius: 8
            samples: 17
            color: root.matrixColor
            spread: 0.2
        }
    }
    
    // =========================================================================
    // SHAKE ANIMATION (for LoginBox)
    // =========================================================================
    
    transform: Translate { id: shakeTr; x: 0 }
    
    SequentialAnimation {
        id: shakeAnim
        loops: 2
        NumberAnimation { target: shakeTr; property: "x"; to: 10; duration: 50 }
        NumberAnimation { target: shakeTr; property: "x"; to: -10; duration: 50 }
        NumberAnimation { target: shakeTr; property: "x"; to: 0; duration: 50 }
    }
    
    // =========================================================================
    // CONTENT
    // =========================================================================
    
    Column {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 15
        
        // --- HEADER ---
        Text {
            text: "> MATRIX SYSTEM LOGIN"
            color: root.matrixColor
            font.family: monoFont.name
            font.pixelSize: 16
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            
            layer.enabled: true
            layer.effect: Glow { radius: 6; samples: 13; color: root.matrixColor; spread: 0.3 }
        }
        
        Rectangle { width: parent.width; height: 1; color: root.matrixColor; opacity: 0.5 }
        
        // --- USER SECTION ---
        Row {
            spacing: 15
            
            // Avatar - Neo's Glasses with Pills
            Rectangle {
                width: 100
                height: 100
                color: "transparent"
                border.color: root.matrixColor
                border.width: 1
                radius: 4
                visible: root.showAvatar
                
                // Matrix Avatar Canvas - Neo's Glasses
                Canvas {
                    id: avatarCanvas
                    anchors.fill: parent
                    anchors.margins: 2
                    
                    property var katakanaChars: [
                        "ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ",
                        "サ", "シ", "ス", "セ", "ソ", "タ", "チ", "ツ", "テ", "ト"
                    ]
                    
                    property var latinChars: [
                        "A", "B", "C", "D", "E", "F", "G", "H", "K", "M", "N", "R", "S", "T", "V", "W", "X", "Z"
                    ]
                    
                    property var numberChars: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
                    
                    property var allChars: katakanaChars.concat(latinChars).concat(numberChars)
                    
                    function isInsideGlasses(x, y, w, h) {
                        var nx = x / w
                        var ny = y / h
                        
                        // GLASSES
                        var glassesCenterY = 0.35
                        var lensRadius = 0.18
                        
                        // Left lens
                        var leftCenterX = 0.3
                        var dx = nx - leftCenterX
                        var dy = ny - glassesCenterY
                        if (dx * dx + dy * dy < lensRadius * lensRadius) return true
                        
                        // Right lens
                        var rightCenterX = 0.7
                        dx = nx - rightCenterX
                        dy = ny - glassesCenterY
                        if (dx * dx + dy * dy < lensRadius * lensRadius) return true
                        
                        // Bridge
                        if (ny > glassesCenterY - 0.02 && ny < glassesCenterY + 0.02 && nx > 0.45 && nx < 0.55) return true
                        
                        // Left temple
                        if (ny > glassesCenterY - 0.02 && ny < glassesCenterY + 0.02 && nx < 0.15) return true
                        
                        // Right temple
                        if (ny > glassesCenterY - 0.02 && ny < glassesCenterY + 0.02 && nx > 0.85) return true
                        
                        // SMILE (straight line - NEUTRAL)
                        var mouthY = 0.7
                        var mouthThickness = 0.025
                        if (nx > 0.3 && nx < 0.7) {
                            if (Math.abs(ny - mouthY) < mouthThickness) return true
                        }
                        
                        return false
                    }
                    
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        
                        ctx.textBaseline = "top"
                        ctx.textAlign = "center"
                        
                        var symbolSize = 5
                        ctx.font = symbolSize + "px monospace"
                        
                        var cols = Math.floor(width / symbolSize)
                        var rows = Math.floor(height / symbolSize)
                        
                        // Draw matrix symbols (glasses + smile)
                        for (var row = 0; row < rows; row++) {
                            for (var col = 0; col < cols; col++) {
                                var x = col * symbolSize + symbolSize / 2
                                var y = row * symbolSize
                                
                                // Check if inside glasses
                                if (!isInsideGlasses(x, y, width, height)) continue
                                
                                // Random symbol
                                var symbol = allChars[Math.floor(Math.random() * allChars.length)]
                                
                                // Random glow (10% chance)
                                var hasGlow = Math.random() < 0.1
                                
                                if (hasGlow) {
                                    // Draw glow
                                    ctx.fillStyle = "#66FF66"
                                    ctx.globalAlpha = 0.4
                                    ctx.fillText(symbol, x + 0.5, y + 0.5)
                                    ctx.fillText(symbol, x - 0.5, y - 0.5)
                                }
                                
                                // Draw main symbol
                                ctx.fillStyle = root.matrixColor.toString()
                                ctx.globalAlpha = 0.7 + Math.random() * 0.3
                                ctx.fillText(symbol, x, y)
                            }
                        }
                        
                        // Draw PILLS
                        ctx.font = "bold 7px monospace"
                        
                        // RED PILL
                        var redSymbol = allChars[Math.floor(Math.random() * allChars.length)]
                        var redX = width * 0.3
                        var redY = height * 0.35
                        var redHasGlow = Math.random() < 0.1
                        
                        if (redHasGlow) {
                            ctx.fillStyle = "#FF6666"
                            ctx.globalAlpha = 0.4
                            ctx.fillText(redSymbol, redX + 0.5, redY + 0.5)
                            ctx.fillText(redSymbol, redX - 0.5, redY - 0.5)
                        }
                        
                        ctx.fillStyle = "#FF0000"
                        ctx.globalAlpha = 1.0
                        ctx.fillText(redSymbol, redX, redY)
                        
                        // BLUE PILL
                        var blueSymbol = allChars[Math.floor(Math.random() * allChars.length)]
                        var blueX = width * 0.7
                        var blueY = height * 0.35
                        var blueHasGlow = Math.random() < 0.1
                        
                        if (blueHasGlow) {
                            ctx.fillStyle = "#6666FF"
                            ctx.globalAlpha = 0.4
                            ctx.fillText(blueSymbol, blueX + 0.5, blueY + 0.5)
                            ctx.fillText(blueSymbol, blueX - 0.5, blueY - 0.5)
                        }
                        
                        ctx.fillStyle = "#0066FF"
                        ctx.globalAlpha = 1.0
                        ctx.fillText(blueSymbol, blueX, blueY)
                        
                        ctx.globalAlpha = 1.0
                    }
                    
                    Timer {
                        interval: 100
                        running: root.showAvatar
                        repeat: true
                        onTriggered: avatarCanvas.requestPaint()
                    }
                }
            }
            
            // User Dropdown
            Column {
                spacing: 6
                
                Text {
                    text: "USER:"
                    color: root.matrixColor
                    font.family: monoFont.name
                    font.pixelSize: 11
                    opacity: 0.7
                }
                
                Rectangle {
                    id: userDrop
                    width: 190
                    height: 38
                    color: Qt.rgba(0, 0.1, 0, 0.5)
                    border.color: root.matrixColor
                    border.width: 1
                    radius: 2
                    
                    property bool open: false
                    
                    Text {
                        text: root.currentUsername || "User"
                        color: root.matrixColor
                        font.family: monoFont.name
                        font.pixelSize: 14
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: userArrow.left
                        anchors.rightMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                    }
                    
                    Text {
                        id: userArrow
                        text: userDrop.open ? "▲" : "▼"
                        color: root.matrixColor
                        font.pixelSize: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            userDrop.open = !userDrop.open
                        }
                    }
                    
                    // Dropdown list
                    Rectangle {
                        width: parent.width
                        height: Math.min((typeof userModel !== 'undefined' ? userModel.count : 1) * 32, 130)
                        anchors.top: parent.bottom
                        anchors.topMargin: 2
                        color: Qt.rgba(0, 0, 0, 0.95)
                        border.color: root.matrixColor
                        border.width: 1
                        radius: 2
                        visible: userDrop.open
                        z: 100
                        clip: true
                        
                        ListView {
                            anchors.fill: parent
                            anchors.margins: 2
                            model: typeof userModel !== 'undefined' ? userModel : null
                            
                            delegate: Rectangle {
                                width: ListView.view ? ListView.view.width : 180
                                height: 32
                                color: delMouse.containsMouse ? Qt.rgba(0, 0.2, 0, 0.6) : "transparent"
                                
                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: model.name || "User"
                                    color: root.matrixColor
                                    font.family: monoFont.name
                                    font.pixelSize: 13
                                }
                                
                                MouseArea {
                                    id: delMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.selectedUserIndex = index
                                        root.currentUsername = model.name || "User"
                                        userDrop.open = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // --- PASSWORD ---
        Column {
            width: parent.width
            spacing: 6
            
            Text {
                text: "PASSWORD:"
                color: root.matrixColor
                font.family: monoFont.name
                font.pixelSize: 11
                opacity: 0.7
            }
            
            Rectangle {
                id: pwdBox
                width: parent.width
                height: 42
                color: Qt.rgba(0, 0.1, 0, 0.5)
                border.color: passwordInput.activeFocus ? root.matrixColor : Qt.darker(root.matrixColor, 1.5)
                border.width: passwordInput.activeFocus ? 2 : 1
                radius: 2
                
                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.margins: 8
                    color: "transparent"
                    echoMode: TextInput.Password
                    font.pixelSize: 1
                    cursorVisible: false
                    cursorDelegate: Item {}
                    focus: false  // Don't auto-focus
                    
                    onTextChanged: {
                        if (text.length > root.passwordMask.length) {
                            for (var i = root.passwordMask.length; i < text.length; i++) {
                                root.passwordMask.push(getRandomKatakana())
                            }
                        } else {
                            root.passwordMask = root.passwordMask.slice(0, text.length)
                        }
                        root.passwordMask = root.passwordMask.slice()
                    }
                    
                    onAccepted: attemptLogin()
                    Keys.onEscapePressed: { text = ""; root.passwordMask = [] }
                }
                
                // Password display with scrolling
                Item {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    height: 24
                    clip: true
                    
                    Row {
                        id: pwdRow
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.min(0, parent.width - width - 15)
                        spacing: 2
                        
                        Text {
                            id: passwordText
                            text: root.getPasswordDisplay()
                            color: root.matrixColor
                            font.family: monoFont.name
                            font.pixelSize: 18
                            font.letterSpacing: 4
                            anchors.verticalCenter: parent.verticalCenter
                            
                            layer.enabled: true
                            layer.effect: Glow { radius: 4; samples: 9; color: root.matrixColor; spread: 0.3 }
                        }
                        
                        Rectangle {
                            width: 10
                            height: passwordText.height
                            color: root.matrixColor
                            visible: passwordInput.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                            
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                running: passwordInput.activeFocus
                                NumberAnimation { to: 0; duration: 530 }
                                NumberAnimation { to: 1; duration: 530 }
                            }
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: passwordInput.forceActiveFocus()
                }
            }
        }

        // --- LOGIN BUTTON ---
        Rectangle {
            width: 160
            height: 42
            anchors.horizontalCenter: parent.horizontalCenter
            color: loginMouse.containsMouse ? Qt.rgba(0, 0.3, 0, 0.8) : Qt.rgba(0, 0.15, 0, 0.5)
            border.color: root.matrixColor
            border.width: 2
            radius: 2
            
            Text {
                anchors.centerIn: parent
                text: root.isLoggingIn ? "CONNECTING..." : "> LOGIN"
                color: root.matrixColor
                font.family: monoFont.name
                font.pixelSize: 14
                font.bold: true
            }
            
            MouseArea {
                id: loginMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                enabled: !root.isLoggingIn
                onClicked: attemptLogin()
            }
            
            layer.enabled: true
            layer.effect: Glow { radius: loginMouse.containsMouse ? 10 : 4; samples: 17; color: root.matrixColor; spread: 0.2 }
        }
        
        // --- SESSION SELECTOR ---
        Item {
            width: parent.width
            height: 35
            
            Rectangle {
                id: sessDrop
                width: 170
                height: 28
                anchors.centerIn: parent
                color: "transparent"
                border.color: root.matrixColor
                border.width: 1
                radius: 2
                opacity: 0.8
                
                property bool open: false
                
                Text {
                    text: root.currentSessionName
                    color: root.matrixColor
                    font.family: monoFont.name
                    font.pixelSize: 11
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: sessArrow.left
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                }
                
                Text {
                    id: sessArrow
                    text: sessDrop.open ? "▲" : "▼"
                    color: root.matrixColor
                    font.pixelSize: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sessDrop.open = !sessDrop.open
                    }
                }
                
                // Session dropdown list
                Rectangle {
                    width: parent.width
                    height: Math.min((typeof sessionModel !== 'undefined' ? sessionModel.count : 1) * 28, 100)
                    anchors.top: parent.bottom
                    anchors.topMargin: 2
                    color: Qt.rgba(0, 0, 0, 0.95)
                    border.color: root.matrixColor
                    border.width: 1
                    radius: 2
                    visible: sessDrop.open
                    z: 100
                    clip: true
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 2
                        model: typeof sessionModel !== 'undefined' ? sessionModel : null
                        
                        delegate: Rectangle {
                            width: ListView.view ? ListView.view.width : 160
                            height: 28
                            color: sessMouse.containsMouse ? Qt.rgba(0, 0.2, 0, 0.6) : "transparent"
                            
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: model.name || "Session"
                                color: root.matrixColor
                                font.family: monoFont.name
                                font.pixelSize: 11
                            }
                            
                            MouseArea {
                                id: sessMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedSessionIndex = index
                                    root.currentSessionName = model.name || "Session"
                                    sessDrop.open = false
                                }
                            }
                        }
                    }
                }
            }
            
            Text {
                text: "SESSION:"
                color: root.matrixColor
                font.family: monoFont.name
                font.pixelSize: 11
                opacity: 0.6
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: sessDrop.left
                anchors.rightMargin: 10
            }
        }
        
        Item { width: 1; height: 10 }
    }
    
    // --- POWER BUTTONS ---
    Row {
        width: parent.width - 50
        height: 110
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 25
        
        Item {
            width: parent.width / 3
            height: parent.height
            
            Rectangle {
                width: 100; height: 100; radius: 50
                anchors.centerIn: parent
                color: shutMouse.containsMouse ? Qt.rgba(0.3, 0, 0, 0.5) : "transparent"
                border.color: root.matrixColor; border.width: 2
                opacity: shutMouse.containsMouse ? 1.0 : 0.6
                
                Text { 
                    anchors.centerIn: parent
                    text: "⏻"
                    color: shutMouse.containsMouse ? "#FF6666" : root.matrixColor
                    font.pixelSize: 44
                }
                MouseArea { 
                    id: shutMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sddm.powerOff()
                    }
                }
            }
        }
        
        Item {
            width: parent.width / 3
            height: parent.height
            
            Rectangle {
                width: 100; height: 100; radius: 50
                anchors.centerIn: parent
                color: rebootMouse.containsMouse ? Qt.rgba(0, 0.2, 0, 0.5) : "transparent"
                border.color: root.matrixColor; border.width: 2
                opacity: rebootMouse.containsMouse ? 1.0 : 0.6
                
                Text {
                    anchors.centerIn: parent
                    text: "↻"
                    color: root.matrixColor
                    font.pixelSize: 48
                }
                MouseArea {
                    id: rebootMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sddm.reboot()
                    }
                }
            }
        }
        
        Item {
            width: parent.width / 3
            height: parent.height
            
            Rectangle {
                width: 100; height: 100; radius: 50
                anchors.centerIn: parent
                color: sleepMouse.containsMouse ? Qt.rgba(0, 0, 0.2, 0.5) : "transparent"
                border.color: root.matrixColor; border.width: 2
                opacity: sleepMouse.containsMouse ? 1.0 : 0.6
                
                Text {
                    anchors.centerIn: parent
                    text: "◐"
                    color: sleepMouse.containsMouse ? "#6666FF" : root.matrixColor
                    font.pixelSize: 44
                }
                MouseArea {
                    id: sleepMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sddm.suspend()
                    }
                }
            }
        }
    }
    
    // =========================================================================
    // ERROR POPUP (top layer)
    // =========================================================================
    
    Rectangle {
        id: errorPopup
        width: 630  // 1.5 × LoginBox width (420 × 1.5)
        height: 100
        anchors.centerIn: parent
        color: Qt.rgba(0.3, 0, 0, 0.10)
        border.color: "#FF0000"
        border.width: 2
        radius: 4
        visible: root.showError
        opacity: root.showError ? 1.0 : 0.0
        z: 1000  // top layer
        
        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }
        
        // Glow effect for border
        layer.enabled: true
        layer.effect: Glow {
            radius: 10
            samples: 21
            color: "#FF0000"
            spread: 0.4
        }
        
        // Error message
        Text {
            anchors.centerIn: parent
            text: "> " + root.errorMessage
            color: root.errorColor
            font.family: monoFont.name
            font.pixelSize: 50  // Increased for better reading
            font.bold: true
            
            layer.enabled: true
            layer.effect: Glow {
                radius: 1
                samples: 13
                color: root.errorColor
                spread: 0.3
            }
        }
        
        // Shake for popup
        transform: Translate { id: errorShakeTr; x: 0 }
    }
    
    // Shake animation for popup window
    SequentialAnimation {
        id: errorShakeAnim
        loops: 2
        NumberAnimation { target: errorShakeTr; property: "x"; to: 15; duration: 50 }
        NumberAnimation { target: errorShakeTr; property: "x"; to: -15; duration: 50 }
        NumberAnimation { target: errorShakeTr; property: "x"; to: 0; duration: 50 }
    }
}