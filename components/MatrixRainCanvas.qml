// =============================================================================
// MATRIX RAIN CANVAS - Matrix Trilogy SDDM Theme
// =============================================================================

import QtQuick 2.15

Item {
    id: root
    
    // =========================================================================
    // PROPERTIES
    // =========================================================================
    
    property color matrixColor: "#00FF41"
    property color darkColor: "#003B00"
    property real speed: 1.0
    property real depth: 0.5
    property real changeRate: 0.3
    property real glow: 0.6
    property real density: 1.0
    property real timeOffset: 0.0
    
    // Cached color strings to avoid per-character toString() calls
    property string matrixColorStr: matrixColor.toString()
    property string darkColorStr: darkColor.toString()
    
    // Animation time (grows infinitely - no loop jumps!)
    property real animationTime: 0.0
    
    // =========================================================================
    // ANIMATION (continuous, no reset)
    // =========================================================================
    
    Timer {
        interval: 33  // ~30 FPS
        running: true
        repeat: true
        onTriggered: {
            root.animationTime += 0.033
        }
    }
    
    // =========================================================================
    // CANVAS - The Rain!
    // =========================================================================
    
    Canvas {
        id: rainCanvas
        anchors.fill: parent
        
        // Character sets
        property var katakanaChars: [
            "ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ",
            "サ", "シ", "ス", "セ", "ソ", "タ", "チ", "ツ", "テ", "ト",
            "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ",
            "マ", "ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ",
            "ル", "レ", "ロ", "ワ", "ヲ", "ン"
        ]
        
        property var latinChars: [
            "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
            "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
        ]
        
        property var numberChars: [
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
        ]
        
        // Combined character set
        property var allChars: katakanaChars.concat(latinChars).concat(numberChars)
        
        // Column data (pre-generated for consistent animation)
        property var columns: []
        property bool initialized: false
        
        // =====================================================================
        // INITIALIZATION
        // =====================================================================
        
        function initColumns() {
            
            var spacing = 40 / root.density
            var cols = Math.floor(width / spacing)
            
            columns = []
            
            for (var i = 0; i < cols; i++) {
                var col = {
                    x: i * spacing,
                    speed: (0.5 + Math.random() * 0.5) * root.speed,
                    length: 8 + Math.floor(Math.random() * 12),
                    startY: Math.random() * height * 2 - height,
                    chars: [],
                    changeCounters: []
                }
                
                // Pre-generate characters for this column
                for (var j = 0; j < 30; j++) {
                    col.chars.push(allChars[Math.floor(Math.random() * allChars.length)])
                    col.changeCounters.push(Math.random() * 10)
                }
                
                columns.push(col)
            }
            
            initialized = true
        }
        
        // =====================================================================
        // DRAWING
        // =====================================================================
        
        onPaint: {
            if (!initialized) return
            
            var ctx = getContext("2d")
            if (!ctx) return
            
            // Clear canvas
            ctx.fillStyle = "#000000"
            ctx.fillRect(0, 0, width, height)
            
            ctx.textBaseline = "top"
            ctx.textAlign = "center"
            
            var time = root.animationTime + root.timeOffset
            
            // Reduced to 3 depth layers (was 5)
            var depthLayers = [
                { size: 14, speed: 0.4, opacity: 0.3, offset: 5 },   // Far
                { size: 18, speed: 0.8, opacity: 0.7, offset: 0 },   // Mid
                { size: 22, speed: 1.2, opacity: 1.0, offset: -5 }   // Near
            ]
            
            // Cache color strings locally for the render loop
            var matrixColorStr = root.matrixColorStr
            var darkColorStr = root.darkColorStr
            
            for (var layerIdx = 0; layerIdx < depthLayers.length; layerIdx++) {
                var layer = depthLayers[layerIdx]
                
                ctx.font = layer.size + "px 'Noto Sans JP', 'Noto Sans Mono CJK JP', monospace"
                
                // Horizontal drift for depth effect
                var drift = Math.sin(time * root.depth * 0.3 + layerIdx * 1.5) * 30 * root.depth
                
                for (var i = 0; i < columns.length; i++) {
                    var col = columns[i]
                    
                    var seed1 = Math.sin(i * 12.9898 + layerIdx * 78.233) * 43758.5453
                    var seed2 = Math.cos(i * 45.567 + layerIdx * 23.891) * 31234.1234
                    var randomX = (Math.abs(seed1 - Math.floor(seed1)) - 0.5) * 50
                    var randomX2 = (Math.abs(seed2 - Math.floor(seed2)) - 0.5) * 30
                    
                    var x = col.x + layer.offset + drift + randomX + randomX2
                    
                    // Calculate Y position with speed
                    var totalHeight = height + col.length * layer.size * 1.3
                    var rawY = col.startY + time * 120 * col.speed * layer.speed
                    var y = (rawY % totalHeight) - col.length * layer.size
                    
                    // Draw column (head at BOTTOM, tail at TOP)
                    for (var j = 0; j < col.length; j++) {
                        var charY = y + j * layer.size * 1.2
                        
                        // Skip if outside visible area
                        if (charY < -layer.size || charY > height + layer.size) continue
                        
                        // Get character (with occasional changes)
                        var charIdx = j % col.chars.length
                        
                        // Change character randomly in tail (top part)
                        if (j < col.length - 2 && Math.random() < root.changeRate * 0.02) {
                            col.chars[charIdx] = allChars[Math.floor(Math.random() * allChars.length)]
                        }
                        
                        var symbol = col.chars[charIdx]
                        
                        // HEAD = constantly changing white symbol (BOTTOM of column)
                        if (j === col.length - 1) {
                            symbol = allChars[Math.floor(Math.random() * allChars.length)]
                            ctx.fillStyle = "#FFFFFF"
                            ctx.globalAlpha = layer.opacity
                        }
                        // Second from bottom = bright green
                        else if (j === col.length - 2) {
                            ctx.fillStyle = "#66FF66"
                            ctx.globalAlpha = layer.opacity * 0.95
                        }
                        // TAIL = fading green (TOP part of column)
                        else {
                            var distanceFromHead = col.length - 1 - j
                            var fade = 1.0 - (distanceFromHead / col.length)
                            
                            if (fade > 0.6) {
                                ctx.fillStyle = matrixColorStr
                            } else if (fade > 0.3) {
                                ctx.fillStyle = "#00DD30"
                            } else {
                                ctx.fillStyle = darkColorStr
                            }
                            
                            ctx.globalAlpha = layer.opacity * (0.3 + fade * 0.7)
                        }
                        
                        // Draw character
                        ctx.fillText(symbol, x, charY)
                    }
                }
            }
            
            ctx.globalAlpha = 1.0
        }
        
        // =====================================================================
        // UPDATE TIMER
        // =====================================================================
        
        Timer {
            interval: 33  // ~30 FPS
            running: true
            repeat: true
            onTriggered: rainCanvas.requestPaint()
        }
        
        // =====================================================================
        // INITIALIZATION
        // =====================================================================
        
        Component.onCompleted: {
            initTimer.start()
        }
        
        Timer {
            id: initTimer
            interval: 100
            running: false
            onTriggered: {
                rainCanvas.initColumns()
                rainCanvas.requestPaint()
            }
        }
        
        onWidthChanged: {
            if (width > 0 && height > 0) {
                initColumns()
            }
        }
        
        onHeightChanged: {
            if (width > 0 && height > 0) {
                initColumns()
            }
        }
    }
}
