// =============================================================================
// KEYBOARD INDICATOR COMPONENT - Matrix Trilogy SDDM Theme
// =============================================================================

import QtQuick 2.15
import QtGraphicalEffects 1.15
import SddmComponents 2.0

Item {
    id: root
    
    // =========================================================================
    // PROPERTIES
    // =========================================================================
    
    property color textColor: "#00FF41"
    property color glowColor: "#00FF41"
    property int fontSize: 14
    
    // Current layout short name
    property string currentLayoutName: "EN"
    
    // Is keyboard object available?
    property bool keyboardAvailable: false
    
    // Auto-size based on content
    width: layoutRow.width
    height: layoutRow.height
    
    // =========================================================================
    // FONT
    // =========================================================================
    
    FontLoader {
        id: monoFont
        source: "../fonts/JetBrainsMono-Regular.ttf"
    }
    
    // =========================================================================
    // KEYBOARD CONNECTIONS - Listen for layout changes
    // =========================================================================
    
    Connections {
        target: typeof keyboard !== 'undefined' ? keyboard : null
        ignoreUnknownSignals: true
        
        function onCurrentLayoutChanged() {
            updateLayout()
        }
    }
    
    // =========================================================================
    // FUNCTIONS
    // =========================================================================
    
    function shortenLayoutName(longName) {
        // Convert long names to short codes
        if (!longName || longName.length === 0) return "EN"
        
        var name = longName.toString().toLowerCase()
        
        // IMPORTANT: Check "russian" BEFORE "us" (because "russian" contains "us")
        if (name.indexOf("russia") !== -1 || name.indexOf("russian") !== -1) {
            return "RU"
        } else if (name.indexOf("english") !== -1 || name.indexOf("us") !== -1) {
            return "EN"
        } else if (name.indexOf("german") !== -1 || name.indexOf("deutsch") !== -1) {
            return "DE"
        } else if (name.indexOf("french") !== -1 || name.indexOf("français") !== -1) {
            return "FR"
        } else if (name.indexOf("spanish") !== -1 || name.indexOf("español") !== -1) {
            return "ES"
        } else if (name.indexOf("chinese") !== -1 || name.indexOf("中文") !== -1) {
            return "ZH"
        } else if (name.indexOf("japanese") !== -1 || name.indexOf("日本") !== -1) {
            return "JP"
        } else if (name.indexOf("italian") !== -1) {
            return "IT"
        } else if (name.indexOf("portuguese") !== -1) {
            return "PT"
        } else if (name.indexOf("polish") !== -1) {
            return "PL"
        } else if (name.indexOf("ukrainian") !== -1) {
            return "UA"
        } else if (name.indexOf("arabic") !== -1) {
            return "AR"
        } else {
            // Take first 2 letters and uppercase
            return longName.substring(0, 2).toUpperCase()
        }
    }
    
    function checkKeyboardAvailable() {
        if (typeof keyboard === 'undefined' || !keyboard) {
            return false
        }
        
        if (!keyboard.layouts || keyboard.layouts.length === 0) {
            return false
        }
        
        return true
    }
    
    function updateLayout() {
        // Check if keyboard exists
        if (!checkKeyboardAvailable()) {
            currentLayoutName = "EN"
            keyboardAvailable = false
            return
        }
        
        keyboardAvailable = true
        
        try {
            var currentLayout = null
            
            // Check if currentLayout is a number (index) or object
            if (typeof keyboard.currentLayout === 'number') {
                if (keyboard.currentLayout >= 0 && keyboard.currentLayout < keyboard.layouts.length) {
                    currentLayout = keyboard.layouts[keyboard.currentLayout]
                } else {
                    currentLayout = keyboard.layouts[0]
                }
            } else {
                currentLayout = keyboard.currentLayout || keyboard.layouts[0]
            }
            
            var layoutName = ""
            
            if (currentLayout.longName && currentLayout.longName.length > 0) {
                layoutName = shortenLayoutName(currentLayout.longName)
            } else if (currentLayout.shortName && currentLayout.shortName.length > 0) {
                layoutName = currentLayout.shortName
            } else if (currentLayout.name && currentLayout.name.length > 0) {
                layoutName = currentLayout.name
            } else {
                layoutName = "EN"
            }
            
            currentLayoutName = layoutName
        } catch (e) {
            currentLayoutName = "EN"
        }
    }
    
    function switchLayout() {
        if (!checkKeyboardAvailable()) {
            return
        }
        
        try {
            var layoutCount = keyboard.layouts.length
            
            if (layoutCount <= 1) {
                return
            }
            
            // Find current layout index
            var currentIdx = -1
            
            if (typeof keyboard.currentLayout === 'number') {
                currentIdx = keyboard.currentLayout
            } else {
                for (var i = 0; i < layoutCount; i++) {
                    if (keyboard.layouts[i] === keyboard.currentLayout) {
                        currentIdx = i
                        break
                    }
                }
            }
            
            if (currentIdx < 0) {
                currentIdx = 0
            }
            
            // Calculate next index
            var nextIdx = (currentIdx + 1) % layoutCount
            
            // Try to switch (Method 1: assign index)
            try {
                keyboard.currentLayout = nextIdx
            } catch (e1) {
                // Method 2: assign object
                try {
                    keyboard.currentLayout = keyboard.layouts[nextIdx]
                } catch (e2) {
                    // Method 3: setLayout method
                    if (typeof keyboard.setLayout === 'function') {
                        keyboard.setLayout(nextIdx)
                    } else {
                        return
                    }
                }
            }
            
            // Force update after switch
            updateTimer.start()
        } catch (e) {
        }
    }
    
    // Timer to update display after switch
    Timer {
        id: updateTimer
        interval: 100
        repeat: false
        onTriggered: updateLayout()
    }
    
    // =========================================================================
    // DISPLAY
    // =========================================================================
    
    Row {
        id: layoutRow
        spacing: 8
        
        // Layout name (main display)
        Text {
            id: layoutText
            text: root.currentLayoutName
            color: root.textColor
            font.family: monoFont.status === FontLoader.Ready ? monoFont.name : "monospace"
            font.pixelSize: root.fontSize
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            
            layer.enabled: true
            layer.effect: Glow {
                radius: 4
                samples: 9
                color: root.glowColor
                spread: 0.2
            }
        }
        
        // Arrow indicator (shows it's clickable)
        Text {
            text: "⇄"
            color: root.textColor
            font.pixelSize: root.fontSize
            opacity: layoutMouse.containsMouse ? 0.9 : 0.4
            anchors.verticalCenter: parent.verticalCenter
            visible: root.keyboardAvailable
            
            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }
    }
    
    // =========================================================================
    // MOUSE AREA - Click to switch layout
    // =========================================================================
    
    MouseArea {
        id: layoutMouse
        anchors.fill: parent
        anchors.margins: -8
        hoverEnabled: true
        cursorShape: root.keyboardAvailable ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.keyboardAvailable
        
        onClicked: switchLayout()
    }
    
    // Hover effect - subtle scale
    scale: (layoutMouse.containsMouse && root.keyboardAvailable) ? 1.08 : 1.0
    
    Behavior on scale {
        NumberAnimation { duration: 100 }
    }
    
    // =========================================================================
    // INITIALIZATION
    // =========================================================================
    
    Component.onCompleted: {

        // Check if keyboard exists
        if (typeof keyboard === 'undefined' || !keyboard) {
            keyboardAvailable = false
            currentLayoutName = "EN"
            return
        }
        
        // Check if layouts exist
        if (!keyboard.layouts || keyboard.layouts.length === 0) {
            keyboardAvailable = false
            currentLayoutName = "EN"
            return
        }
        
        // Everything OK
        keyboardAvailable = true
        updateLayout()
    }
    
    // =========================================================================
    // POLLING TIMER - Fallback if Connections don't work
    // =========================================================================
    
    Timer {
        interval: 500
        running: root.keyboardAvailable
        repeat: true
        
        onTriggered: {
            if (typeof keyboard !== 'undefined' && keyboard && keyboard.currentLayout) {
                try {
                    var currentLayout = null
                    
                    if (typeof keyboard.currentLayout === 'number') {
                        currentLayout = keyboard.layouts[keyboard.currentLayout]
                    } else {
                        currentLayout = keyboard.currentLayout
                    }
                    
                    if (currentLayout) {
                        var rawName = currentLayout.longName || 
                                     currentLayout.shortName || 
                                     currentLayout.name || 
                                     ""
                        
                        if (rawName.length > 0) {
                            var newLayout = shortenLayoutName(rawName)
                            
                            if (newLayout !== root.currentLayoutName) {
                                root.currentLayoutName = newLayout
                            }
                        }
                    }
                } catch (e) {
                    // Ignore errors
                }
            }
        }
    }
}