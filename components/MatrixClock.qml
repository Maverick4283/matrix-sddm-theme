// =============================================================================
// MATRIX CLOCK COMPONENT - Matrix Trilogy SDDM Theme
// =============================================================================

import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    // =========================================================================
    // PUBLIC PROPERTIES
    // =========================================================================
    
    // --- Appearance ---
    // Text color (Matrix green)
    property color textColor: "#00FF41"
    
    // Glow color
    property color glowColor: "#00FF41"
    
    // Scale factor (driven by Main.qml)
    property real scaleFactor: 1.0

    // Time font size
    property int timeFontSize: Math.round(64 * scaleFactor)

    // Date font size
    property int dateFontSize: Math.round(28 * scaleFactor)
    
    // --- Format ---
    // Time format (Qt format string)
    // Examples: "HH:mm:ss", "hh:mm:ss AP", "HH:mm"
    property string clockFormat: "HH:mm:ss"
    
    // Date format (Qt format string)
    // Examples: "yyyy.MM.dd", "dddd, MMMM d, yyyy", "dd/MM/yyyy"
    property string dateFormat: "yyyy.MM.dd"
    
    // --- Effects ---
    // Enable scramble effect when digits change
    property bool scrambleEffect: true
    
    // Scramble duration in milliseconds
    property int scrambleDuration: 150
    
    // Minimum interval between scrambles in seconds (to avoid too frequent flashing)
    property int scrambleMinInterval: 3
    
    // Maximum interval between scrambles in seconds
    property int scrambleMaxInterval: 5
    
    // =========================================================================
    // INTERNAL STATE
    // =========================================================================
    
    // Current displayed time and date
    property string currentTime: ""
    property string currentDate: ""
    
    // Previous time (for detecting changes)
    property string previousTime: ""
    
    // Is scrambling?
    property bool isScrambling: false
    
    // Scramble display text
    property string scrambleText: ""
    
    // Last scramble timestamp
    property real lastScrambleTime: 0
    
    // Auto-size based on content
    width: clockColumn.width
    height: clockColumn.height
    
    // =========================================================================
    // FONT LOADER
    // =========================================================================
    
    FontLoader {
        id: monoFont
        source: "../fonts/JetBrainsMono-Regular.ttf"
    }
    
    // =========================================================================
    // RANDOM CHARACTERS FOR SCRAMBLE
    // =========================================================================
    
    // Characters to use for scramble effect (mix of digits and Matrix-style chars)
    property string scrambleChars: "0123456789アイウエオカキクケコ:."
    
    function getRandomChar() {
        var index = Math.floor(Math.random() * scrambleChars.length)
        return scrambleChars.charAt(index)
    }
    
    function generateScrambleText(length) {
        var result = ""
        for (var i = 0; i < length; i++) {
            result += getRandomChar()
        }
        return result
    }
    
    // =========================================================================
    // TIME UPDATE LOGIC
    // =========================================================================
    
    function updateTime() {
        var now = new Date()
        var newTime = Qt.formatTime(now, clockFormat)
        var newDate = Qt.formatDate(now, dateFormat)
        
        // Get current timestamp in seconds
        var currentTimestamp = now.getTime() / 1000
        
        // Check if enough time passed since last scramble
        var timeSinceLastScramble = currentTimestamp - lastScrambleTime
        var randomInterval = scrambleMinInterval + Math.random() * (scrambleMaxInterval - scrambleMinInterval)
        
        // Check if time changed and enough time passed
        if (newTime !== previousTime && scrambleEffect && timeSinceLastScramble >= randomInterval) {
            // Trigger scramble effect
            startScramble(newTime)
            lastScrambleTime = currentTimestamp
        } else if (!isScrambling) {
            currentTime = newTime
        }
        
        currentDate = newDate
        previousTime = newTime
    }
    
    function startScramble(targetTime) {
        isScrambling = true
        scrambleCount = 0
        targetTimeText = targetTime
        scrambleTimer.start()
    }
    
    property int scrambleCount: 0
    property int maxScrambles: 5
    property string targetTimeText: ""
    
    // =========================================================================
    // TIMERS
    // =========================================================================
    
    // Main clock update timer
    Timer {
        id: clockTimer
        interval: 100  // Update every 100ms for smooth seconds
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: updateTime()
    }
    
    // Scramble effect timer
    Timer {
        id: scrambleTimer
        interval: root.scrambleDuration / root.maxScrambles
        repeat: true
        running: false
        
        onTriggered: {
            scrambleCount++
            
            if (scrambleCount >= maxScrambles) {
                // Scramble complete, show real time
                scrambleTimer.stop()
                isScrambling = false
                currentTime = targetTimeText
            } else {
                // Show random characters
                scrambleText = generateScrambleText(targetTimeText.length)
            }
        }
    }
    
    // =========================================================================
    // DISPLAY
    // =========================================================================
    
    Column {
        id: clockColumn
        spacing: 8
        
        // Time display
        Text {
            id: timeText
            text: root.isScrambling ? root.scrambleText : root.currentTime
            color: root.textColor
            font.family: monoFont.status === FontLoader.Ready ? monoFont.name : "monospace"
            font.pixelSize: root.timeFontSize
            font.bold: false
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            
            // Glow effect
            layer.enabled: true
            layer.effect: Glow {
                radius: 12
                samples: 25
                color: root.glowColor
                spread: 0.4
            }
        }
        
        // Date display
        Text {
            id: dateText
            text: root.currentDate
            color: root.textColor
            font.family: monoFont.status === FontLoader.Ready ? monoFont.name : "monospace"
            font.pixelSize: root.dateFontSize
            font.bold: false
            opacity: 0.8
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            
            // Subtle glow
            layer.enabled: true
            layer.effect: Glow {
                radius: 8
                samples: 17
                color: root.glowColor
                spread: 0.3
            }
        }
    }
}