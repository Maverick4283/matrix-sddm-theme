// =============================================================================
// MATRIX TRILOGY SDDM THEME - Main Entry Point
// =============================================================================

import QtQuick
import QtQuick.Window
import QtQuick.Controls
import SddmComponents 2.0

import "components"

Rectangle {
    id: root
    
    // ==========================================================================
    // THEME CONFIGURATION
    // ==========================================================================
    
    property color matrixGreen: config.MatrixGreen || "#00FF41"
    property color matrixDarkGreen: config.MatrixDarkGreen || "#003B00"
    property color backgroundColor: config.BackgroundColor || "#000000"
    property color glowColor: config.GlowColor || "#00FF41"
    property color redPillColor: config.RedPillColor || "#FF0000"
    property color bluePillColor: config.BluePillColor || "#0066FF"
    
    property int leftMonitorOffset: parseInt(config.LeftMonitorTimeOffset) || 20
    property int centerMonitorOffset: parseInt(config.CenterMonitorTimeOffset) || 60
    property int rightMonitorOffset: parseInt(config.RightMonitorTimeOffset) || 40
    
    property real fallSpeed: parseFloat(config.FallSpeed) || 1.0
    property real depthSpeed: parseFloat(config.DepthSpeed) || 0.5
    property real symbolChangeRate: parseFloat(config.SymbolChangeRate) || 0.3
    property real glowIntensity: parseFloat(config.GlowIntensity) || 0.6
    
    property bool introEnabled: {
        var val = config.IntroEnabled
        if (val === "false" || val === false) return false
        return true
    }
    property int introDuration: parseInt(config.IntroDuration) || 6
    property int typewriterSpeed: parseInt(config.TypewriterSpeed) || 50
    property bool introSkippable: {
        var val = config.IntroSkippable
        if (val === "false" || val === false) return false
        return true
    }
    property var introLines: ["Wake up, Neo...", "The Matrix has you...", "Follow the white rabbit..."]
    
    property bool quotesEnabled: {
        var val = config.QuotesEnabled
        if (val === "false" || val === false) return false
        return true
    }
    property int quoteChangeInterval: parseInt(config.QuoteChangeInterval) || 10
    property var quotesList: [
        '"There is no spoon." - Neo',
        '"Free your mind." - Morpheus',
        '"Welcome to the real world." - Morpheus',
        '"The Matrix has you." - Trinity',
        '"I know kung fu." - Neo',
        '"What is real?" - Morpheus'
    ]
    
    property bool showClock: config.ShowClock === "true"
    property bool showMatrixAvatar: config.ShowMatrixAvatar === "true"
    property string passwordCharStyle: config.PasswordCharStyle || "katakana"
    property bool handsEnabled: config.HandsEnabled === "true"
    
    // ==========================================================================
    // INTERNAL STATE
    // ==========================================================================
    
    property bool introComplete: false
    property int currentScreen: 0
    property int monitorCount: Qt.application.screens ? Qt.application.screens.length : 1
    property real scaleFactor: Math.min(width / 1920.0, height / 1080.0)
    color: backgroundColor
    anchors.fill: parent
    
    // IMPORTANT: Ensure root has focus during intro
    focus: true
    
    // ==========================================================================
    // FONTS
    // ==========================================================================
    
    FontLoader {
        id: matrixFont
        source: "fonts/matrix-code.ttf"
        onStatusChanged: {
            if (status === FontLoader.Error) {
                console.warn("Matrix font not found, using fallback")
            }
        }
    }
    
    FontLoader {
        id: uiFont
        source: "fonts/JetBrainsMono-Regular.ttf"
        onStatusChanged: {
            if (status === FontLoader.Error) {
                console.warn("UI font not found, using system default")
            }
        }
    }
    
    // ==========================================================================
    // SCREEN DETECTION
    // ==========================================================================
    function getScreenType() {
        if (monitorCount <= 1) {
            return "center"
        }
        
        var screens = []
        for (var i = 0; i < screenModel.rowCount(); i++) {
            screens.push({
                index: i,
                x: screenModel.geometry(i).x,
                width: screenModel.geometry(i).width,
                primary: i === screenModel.primary
            })
        }
        
        screens.sort(function(a, b) { return a.x - b.x })
        
        var currentX = root.Screen.virtualX
        var screenIndex = 0
        for (var j = 0; j < screens.length; j++) {
            if (Math.abs(screens[j].x - currentX) < 100) {
                screenIndex = j
                break
            }
        }
        
        if (screens.length === 2) {
            return screenIndex === 0 ? "left" : "center"
        } else if (screens.length >= 3) {
            if (screenIndex === 0) return "left"
            if (screenIndex === screens.length - 1) return "right"
            return "center"
        }
        
        return "center"
    }
    
    property string screenType: getScreenType()
    
    // ==========================================================================
    // BACKGROUND - Matrix Rain
    // ==========================================================================
    
    MatrixRainCanvas {
        id: matrixRain
        anchors.fill: parent
        
        matrixColor: root.matrixGreen
        darkColor: root.matrixDarkGreen
        speed: root.fallSpeed
        depth: root.depthSpeed
        changeRate: root.symbolChangeRate
        glow: root.glowIntensity
        
        timeOffset: {
            switch(screenType) {
                case "left": return root.leftMonitorOffset
                case "right": return root.rightMonitorOffset
                default: return root.centerMonitorOffset
            }
        }
    }
      
    // ==========================================================================
    // CENTER SCREEN - Intro + Login
    // ==========================================================================
    
    Item {
        id: centerContent
        anchors.fill: parent
        visible: screenType === "center"
        
        // --- Intro ---
        TypeWriter {
            id: introSequence
            anchors.centerIn: parent
            visible: root.introEnabled && !root.introComplete
            
            mode: "intro"
            lines: root.introLines
            typingSpeed: root.typewriterSpeed
            textColor: root.matrixGreen
            glowColor: root.glowColor
            fontSize: Math.round(28 * root.scaleFactor)
            
            onCompleted: {
                introCompleteTimer.start()
            }
        }
        
        Timer {
            id: introCompleteTimer
            interval: 1000
            onTriggered: {
                root.introComplete = true
                loginBox.takeFocus()
            }
        }
        
        // --- Login Interface ---
        Item {
            id: loginInterface
            anchors.fill: parent
            opacity: root.introComplete ? 1.0 : 0.0
            visible: opacity > 0
            
            Behavior on opacity {
                NumberAnimation { duration: 800; easing.type: Easing.InOutQuad }
            }
            
            // Clock
            MatrixClock {
                id: clock
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: loginBox.top
                anchors.bottomMargin: Math.round(40 * root.scaleFactor)
                visible: root.showClock

                scaleFactor: root.scaleFactor
                textColor: root.matrixGreen
                glowColor: root.glowColor
                clockFormat: config.ClockFormat || "HH:mm:ss"
                dateFormat: config.DateFormat || "yyyy.MM.dd"
            }
            
            // Login Box
            LoginBox {
                id: loginBox
                anchors.centerIn: parent
                
                matrixColor: root.matrixGreen
                borderColor: root.matrixGreen
                showAvatar: root.showMatrixAvatar
                scaleFactor: root.scaleFactor

                // IMPORTANT: Pass intro state to LoginBox (bind to existing property!)
                introComplete: root.introComplete
                
                onLoginRequest: function(username, password, sessionIndex) {
                    sddm.login(username, password, sessionIndex)
                }
            }
            
            // Quotes
            TypeWriter {
                id: quotesDisplay
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Math.round(60 * root.scaleFactor)
                visible: root.quotesEnabled

                mode: "quotes"
                quotes: root.quotesList
                changeInterval: root.quoteChangeInterval
                typingSpeed: parseInt(config.QuoteTypingSpeed) || 40
                textColor: root.matrixGreen
                glowColor: root.glowColor
                fontSize: Math.round(24 * root.scaleFactor)
            }
            // Start quotes after completion of intro
            Connections {
                target: root
                function onIntroCompleteChanged() {
                    if (root.introComplete && root.quotesEnabled) {
                        quotesDisplay.startQuotes()
                    }
                }
            }
            // Session legend — bottom-left
            Rectangle {
                id: sessionLegend
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.leftMargin: Math.round(22 * root.scaleFactor)
                anchors.bottomMargin: Math.round(80 * root.scaleFactor)

                width:  legendColumn.width  + Math.round(18 * root.scaleFactor)
                height: legendColumn.height + Math.round(18 * root.scaleFactor)

                color:  legendHover.hovered ? "#FFF8C0" : Qt.rgba(0.42, 0.35, 0.08, 0.35)
                radius: 3
                border.color: legendHover.hovered ? "#C8A800" : Qt.rgba(0.24, 0.20, 0.03, 0.4)
                border.width: 1

                Column {
                    id: legendColumn
                    anchors.centerIn: parent
                    spacing: Math.round(6 * root.scaleFactor)

                    Text {
                        text: "SESSIONS:"
                        color: legendHover.hovered ? "#1A1A00" : "#C8A050"
                        font.family: uiFont.name
                        font.pixelSize: Math.round(13 * root.scaleFactor)
                        font.bold: true
                    }

                    Rectangle {
                        width: legendColumn.width
                        height: 1
                        color: legendHover.hovered ? "#C8A800" : "#7A6020"
                        opacity: 0.5
                    }

                    Repeater {
                        model: typeof sessionModel !== 'undefined' ? sessionModel : null

                        delegate: Row {
                            spacing: Math.round(8 * root.scaleFactor)
                            property bool isSelected: index === loginBox.selectedSessionIndex

                            Text {
                                text: String(index + 1)
                                color: legendHover.hovered ? (isSelected ? "#7B3F00" : "#1A1A00") : (isSelected ? "#F0B840" : "#A08030")
                                font.family: uiFont.name
                                font.pixelSize: Math.round(14 * root.scaleFactor)
                                font.bold: isSelected
                            }
                            Text {
                                text: model.name || "Session"
                                color: legendHover.hovered ? (isSelected ? "#7B3F00" : "#1A1A00") : (isSelected ? "#F0B840" : "#A08030")
                                font.family: uiFont.name
                                font.pixelSize: Math.round(14 * root.scaleFactor)
                                font.bold: isSelected
                            }
                        }
                    }
                }

                HoverHandler {
                    id: legendHover
                }
            }

            // Keyboard Indicator
            KeyboardIndicator {
                id: keyboardIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Math.round(20 * root.scaleFactor)

                textColor: root.matrixGreen
                glowColor: root.glowColor
                fontSize: Math.round(14 * root.scaleFactor)
            }

            // Power buttons — top-right of screen
            Row {
                id: powerButtons
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: Math.round(22 * root.scaleFactor)
                anchors.rightMargin: Math.round(22 * root.scaleFactor)
                spacing: Math.round(10 * root.scaleFactor)

                Rectangle {
                    width: Math.round(44 * root.scaleFactor)
                    height: Math.round(44 * root.scaleFactor)
                    radius: Math.round(22 * root.scaleFactor)
                    color: shutBtn.containsMouse ? Qt.rgba(0.3, 0, 0, 0.5) : "transparent"
                    border.color: root.matrixGreen
                    border.width: 1
                    opacity: shutBtn.containsMouse ? 1.0 : 0.55
                    Text {
                        anchors.centerIn: parent
                        text: "⏻"
                        color: shutBtn.containsMouse ? "#FF6666" : root.matrixGreen
                        font.pixelSize: Math.round(20 * root.scaleFactor)
                    }
                    MouseArea {
                        id: shutBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sddm.powerOff()
                    }
                }

                Rectangle {
                    width: Math.round(44 * root.scaleFactor)
                    height: Math.round(44 * root.scaleFactor)
                    radius: Math.round(22 * root.scaleFactor)
                    color: rebootBtn.containsMouse ? Qt.rgba(0, 0.2, 0, 0.5) : "transparent"
                    border.color: root.matrixGreen
                    border.width: 1
                    opacity: rebootBtn.containsMouse ? 1.0 : 0.55
                    Text {
                        anchors.centerIn: parent
                        text: "↻"
                        color: root.matrixGreen
                        font.pixelSize: Math.round(22 * root.scaleFactor)
                    }
                    MouseArea {
                        id: rebootBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sddm.reboot()
                    }
                }

                Rectangle {
                    width: Math.round(44 * root.scaleFactor)
                    height: Math.round(44 * root.scaleFactor)
                    radius: Math.round(22 * root.scaleFactor)
                    color: sleepBtn.containsMouse ? Qt.rgba(0, 0, 0.2, 0.5) : "transparent"
                    border.color: root.matrixGreen
                    border.width: 1
                    opacity: sleepBtn.containsMouse ? 1.0 : 0.55
                    Text {
                        anchors.centerIn: parent
                        text: "◐"
                        color: sleepBtn.containsMouse ? "#6666FF" : root.matrixGreen
                        font.pixelSize: Math.round(20 * root.scaleFactor)
                    }
                    MouseArea {
                        id: sleepBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sddm.suspend()
                    }
                }
            }
        }
    }
    
    // ==========================================================================
    // LEFT SCREEN - Right Hand
    // ==========================================================================
    
    Item {
        id: leftContent
        anchors.fill: parent
        visible: screenType === "left" && root.handsEnabled && monitorCount >= 2
        opacity: root.introComplete ? 1.0 : 0.0
    
        Behavior on opacity {
            NumberAnimation { duration: 1500; easing.type: Easing.InOutQuad }
        }

        MatrixHand {
            id: rightHand
            anchors.centerIn: parent
            
            handType: "right"
            pillColor: root.redPillColor
            symbolColor: root.matrixGreen
            //pillGlowRadius: 25
            // RED PILL
            // Type 2
            pillCoordRanges: [
            {row: 125, colStart: 251, colEnd: 259},    
            {row: 126, colStart: 249, colEnd: 260},
            {row: 127, colStart: 247, colEnd: 262},
            {row: 128, colStart: 245, colEnd: 263},
            {row: 129, colStart: 244, colEnd: 262},
            {row: 130, colStart: 241, colEnd: 260},
            {row: 131, colStart: 239, colEnd: 259},
            {row: 132, colStart: 237, colEnd: 256},
            {row: 133, colStart: 235, colEnd: 254},
            {row: 134, colStart: 232, colEnd: 252},
            {row: 135, colStart: 229, colEnd: 250},
            {row: 136, colStart: 228, colEnd: 248},
            {row: 137, colStart: 227, colEnd: 246},
            {row: 138, colStart: 227, colEnd: 244},
            {row: 139, colStart: 229, colEnd: 242},
            {row: 140, colStart: 232, colEnd: 238},
        ]
        }
    }
    
    // ==========================================================================
    // RIGHT SCREEN - Left Hand
    // ==========================================================================
    
    Item {
        id: rightContent
        anchors.fill: parent
        visible: screenType === "right" && root.handsEnabled && monitorCount >= 3
        opacity: root.introComplete ? 1.0 : 0.0
    
        Behavior on opacity {
            NumberAnimation { duration: 1500; easing.type: Easing.InOutQuad }
        }

        MatrixHand {
            id: leftHand
            anchors.centerIn: parent

            handType: "left"
            symbolColor: root.matrixGreen
            //pillGlowRadius: 25
            // BLUE PILL
            // Type 2
            pillCoordRanges: [
            {row: 131, colStart: 140, colEnd: 146},
            {row: 132, colStart: 137, colEnd: 149},
            {row: 133, colStart: 137, colEnd: 151},
            {row: 134, colStart: 137, colEnd: 153},
            {row: 135, colStart: 138, colEnd: 155},
            {row: 136, colStart: 139, colEnd: 157},
            {row: 137, colStart: 140, colEnd: 159},
            {row: 138, colStart: 142, colEnd: 160},
            {row: 139, colStart: 145, colEnd: 162},
            {row: 140, colStart: 146, colEnd: 164},
            {row: 141, colStart: 147, colEnd: 166},
            {row: 142, colStart: 149, colEnd: 168},
            {row: 143, colStart: 151, colEnd: 170},
            {row: 144, colStart: 153, colEnd: 172},
            {row: 145, colStart: 155, colEnd: 173},
            {row: 146, colStart: 157, colEnd: 171},
            {row: 147, colStart: 159, colEnd: 170},
        ]
        }
    }
    
    // ==========================================================================
    // INPUT - Skip Intro (Mouse + Keyboard)
    // ==========================================================================
    
    MouseArea {
        anchors.fill: parent
        enabled: !root.introComplete && root.introSkippable
        
        onClicked: {
            root.introComplete = true
            loginBox.takeFocus()
        }
    }
    
    Keys.onPressed: function(event) {
        // Skip intro
        if (!root.introComplete && root.introSkippable) {
            root.introComplete = true
            loginBox.takeFocus()
            event.accepted = true
            return
        }

        // Switch keyboard layout (Alt+Shift only)
        if (event.modifiers & Qt.AltModifier && event.key === Qt.Key_Shift) {
            keyboardIndicator.switchLayout()
            event.accepted = true
        }
    }
    
    // ==========================================================================
    // INITIALIZATION
    // ==========================================================================
    
    Component.onCompleted: {
        root.forceActiveFocus()
        
        if (!root.introEnabled) {
            root.introComplete = true
        }
    }
    
    // ==========================================================================
    // SDDM CONNECTIONS
    // ==========================================================================
    
    Connections {
        target: sddm
        
        function onLoginFailed() {
            loginBox.showErrorMessage("Access Denied")
        }
        
        function onLoginSucceeded() {
            // Success - SDDM will handle transition
        }
    }
}
