// =============================================================================
// TYPEWRITER COMPONENT - Matrix Trilogy SDDM Theme
// =============================================================================

import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    // =========================================================================
    // PUBLIC PROPERTIES
    // =========================================================================
    
    property string mode: "intro"
    property var lines: ["Wake up, Neo...", "The Matrix has you...", "Follow the white rabbit..."]
    property var quotes: []
    property int typingSpeed: 50
    property int linePause: 800
    property int changeInterval: 10
    property color textColor: "#00FF41"
    property color glowColor: "#00FF41"
    property int fontSize: 24
    property bool showCursor: true
    property string cursorChar: "█"
    property string prefix: "> "
    
    // =========================================================================
    // SIGNALS
    // =========================================================================
    
    signal completed()
    
    // =========================================================================
    // INTERNAL STATE
    // =========================================================================
    
    property int currentLineIndex: 0
    property int currentQuoteIndex: 0
    property int currentCharIndex: 0
    property string currentFullText: ""
    property string displayedText: ""
    property bool isTyping: false
    property bool isErasing: false
    property bool cursorVisible: true
    
    width: textContainer.width
    height: textContainer.height
    
    // =========================================================================
    // FONTS
    // =========================================================================
    
    FontLoader {
        id: matrixFont
        source: "../fonts/matrix-code.ttf"
    }
    
    FontLoader {
        id: monoFont
        source: "../fonts/JetBrainsMono-Regular.ttf"
    }
    
    // =========================================================================
    // MAIN TEXT DISPLAY
    // =========================================================================
    
    Column {
        id: textContainer
        spacing: 8
        
        // Completed lines
        Repeater {
            model: (mode === "intro" && lines && Array.isArray(lines)) ? currentLineIndex : 0
            
            Text {
                text: prefix + (lines && lines[index] ? lines[index] : "")
                color: root.textColor
                font.family: monoFont.status === FontLoader.Ready ? monoFont.name : "monospace"
                font.pixelSize: root.fontSize
                font.bold: false
                
                layer.enabled: true
                layer.effect: Glow {
                    radius: 8
                    samples: 17
                    color: root.glowColor
                    spread: 0.3
                }
            }
        }
        
        // Currently typing line - CURSOR OUTSIDE OF LAYOUT!
        Item {
            id: currentLineRow
            visible: (mode === "intro" && displayedText.length > 0) || 
                     (isTyping) || 
                     (mode === "quotes" && displayedText.length > 0)
            width: prefixText.width + typingText.width  // NO CURSOR WIDTH!
            height: prefixText.height
            
            Text {
                id: prefixText
                text: root.prefix
                color: root.textColor
                font.family: monoFont.status === FontLoader.Ready ? monoFont.name : "monospace"
                font.pixelSize: root.fontSize
                anchors.left: parent.left
                
                layer.enabled: true
                layer.effect: Glow {
                    radius: 8
                    samples: 17
                    color: root.glowColor
                    spread: 0.3
                }
            }
            
            Text {
                id: typingText
                text: root.displayedText
                color: root.textColor
                font.family: monoFont.status === FontLoader.Ready ? monoFont.name : "monospace"
                font.pixelSize: root.fontSize
                anchors.left: prefixText.right
                
                layer.enabled: true
                layer.effect: Glow {
                    radius: 8
                    samples: 17
                    color: root.glowColor
                    spread: 0.3
                }
            }
            
            // CURSOR - POSITIONED ABSOLUTELY, NOT IN LAYOUT!
            Text {
                id: cursor
                text: root.cursorChar
                color: root.textColor
                font.family: monoFont.status === FontLoader.Ready ? monoFont.name : "monospace"
                font.pixelSize: root.fontSize
                visible: root.showCursor && root.cursorVisible && root.isTyping
                
                // Anchored to end of typing text (not in flow!)
                anchors.left: typingText.right
                anchors.verticalCenter: typingText.verticalCenter
                
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
    
    // =========================================================================
    // CURSOR BLINK TIMER
    // =========================================================================
    
    Timer {
        id: cursorBlinkTimer
        interval: 530
        running: root.showCursor
        repeat: true
        
        onTriggered: {
            root.cursorVisible = !root.cursorVisible
        }
    }
    
    // =========================================================================
    // TYPING TIMER
    // =========================================================================
    
    Timer {
        id: typingTimer
        interval: root.typingSpeed
        repeat: true
        running: false
        
        onTriggered: {
            if (root.isErasing) {
                if (root.currentCharIndex > 0) {
                    root.currentCharIndex--
                    root.displayedText = root.currentFullText.substring(0, root.currentCharIndex)
                } else {
                    root.isErasing = false
                    typingTimer.stop()
                    nextQuoteTimer.start()
                }
            } else {
                if (root.currentCharIndex < root.currentFullText.length) {
                    root.currentCharIndex++
                    root.displayedText = root.currentFullText.substring(0, root.currentCharIndex)
                } else {
                    typingTimer.stop()
                    lineCompleteHandler()
                }
            }
        }
    }
    
    // =========================================================================
    // LINE COMPLETION
    // =========================================================================
    
    function lineCompleteHandler() {
        if (mode === "intro") {
            if (root.currentLineIndex < root.lines.length - 1) {
                linePauseTimer.start()
            } else {
                // Last line - delay before hiding cursor
                cursorDelayTimer.start()
            }
        } else if (mode === "quotes") {
            quoteDisplayTimer.start()
        }
    }
    
    // =========================================================================
    // TIMERS
    // =========================================================================
    
    // Delay before hiding cursor on last line (2 seconds)
    Timer {
        id: cursorDelayTimer
        interval: 2000
        repeat: false
        
        onTriggered: {
            root.isTyping = false
            root.completed()
        }
    }
    
    Timer {
        id: linePauseTimer
        interval: root.linePause
        repeat: false
        
        onTriggered: {
            root.currentLineIndex++
            
            if (root.lines && Array.isArray(root.lines) && root.currentLineIndex < root.lines.length) {
                startTypingLine(root.lines[root.currentLineIndex])
            } else {
                root.isTyping = false
                root.completed()
            }
        }
    }
    
    Timer {
        id: quoteDisplayTimer
        interval: root.changeInterval * 1000
        repeat: false
        
        onTriggered: {
            root.isErasing = true
            typingTimer.interval = root.typingSpeed / 2
            typingTimer.start()
        }
    }
    
    Timer {
        id: nextQuoteTimer
        interval: 300
        repeat: false
        
        onTriggered: {
            root.currentQuoteIndex = (root.currentQuoteIndex + 1) % root.quotes.length
            startTypingLine(root.quotes[root.currentQuoteIndex])
        }
    }
    
    // =========================================================================
    // FUNCTIONS
    // =========================================================================
    
    function startTypingLine(text) {
        root.currentFullText = text
        root.currentCharIndex = 0
        root.displayedText = ""
        root.isTyping = true
        root.isErasing = false
        typingTimer.interval = root.typingSpeed
        typingTimer.start()
    }
    
    function startIntro() {
        if (mode !== "intro") return
        if (!lines || !Array.isArray(lines) || lines.length === 0) {
            root.completed()
            return
        }
        root.currentLineIndex = 0
        startTypingLine(lines[0])
    }
    
    function startQuotes() {
        if (mode !== "quotes" || quotes.length === 0) return
        
        root.currentQuoteIndex = 0
        startTypingLine(quotes[0])
    }
    
    function skip() {
        if (mode === "intro") {
            typingTimer.stop()
            linePauseTimer.stop()
            root.isTyping = false
            root.currentLineIndex = root.lines.length
            root.completed()
        }
    }
    
    function reset() {
        typingTimer.stop()
        linePauseTimer.stop()
        quoteDisplayTimer.stop()
        nextQuoteTimer.stop()
        cursorDelayTimer.stop()
        
        root.currentLineIndex = 0
        root.currentQuoteIndex = 0
        root.currentCharIndex = 0
        root.displayedText = ""
        root.currentFullText = ""
        root.isTyping = false
        root.isErasing = false
    }
    
    // =========================================================================
    // INITIALIZATION
    // =========================================================================
    
    Component.onCompleted: {
        if (mode === "intro" && lines && Array.isArray(lines) && lines.length > 0) {
            startDelayTimer.start()
        }
    }
    
    Timer {
        id: startDelayTimer
        interval: 800
        repeat: false
        onTriggered: {
            startIntro()
        }
    }
}