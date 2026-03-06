// =============================================================================
// MATRIX HAND COMPONENT (STATIC VERSION) - Matrix Trilogy SDDM Theme
// =============================================================================

import QtQuick

Item {
    id: root
    
    // =========================================================================
    // PUBLIC PROPERTIES
    // =========================================================================
    
    // "left" = left hand (blue pill, right monitor)
    // "right" = right hand (red pill, left monitor)
    property string handType: "right"
    
    // Colors
    property color symbolColor: "#00FF41"
    property color pillColor: handType === "right" ? "#FF0000" : "#0066FF"
    
    // =========================================================================
    // PILL COORDINATES (exact pixel-perfect positions)
    // =========================================================================
    
    // Use one of two available Types:
    
    // Type 1: Arrays
    property var pillCoordRanges: [
        // Example: {row: 126, colStart: 252, colEnd: 260}
        // you can fill up your coordinates in here
    ]
    
    // Type 2: Precise coordiates
    property var pillCoordPixels: [
        // Example: {row: 126, col: 252}, {row: 126, col: 253}, ...
        // you can fill up your coordinates in here
    ]
    
    // =========================================================================
    // INTERNAL STATE
    // =========================================================================
    
    property var asciiLines: []
    property bool dataLoaded: false
    
    anchors.fill: parent
    
    // =========================================================================
    // FONT LOADER
    // =========================================================================
    
    FontLoader {
        id: monoFont
        source: Qt.resolvedUrl("../fonts/JetBrainsMono-Regular.ttf")
    }
    
    // =========================================================================
    // LOAD ASCII FROM FILE
    // =========================================================================
    
    function loadASCII() {
        if (!root.visible) {
            return
        }

        var filename = handType === "right" ? "LeftMonitor_reduced.txt" : "RightMonitor_reduced.txt"
        var filepath = "../ascii/" + filename
        
        var xhr = new XMLHttpRequest()
        xhr.open("GET", filepath, true)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 0) {
                    var content = xhr.responseText
                    asciiLines = content.split(/\r?\n/)
                    
                    while (asciiLines.length > 0 && asciiLines[asciiLines.length - 1].trim() === "") {
                        asciiLines.pop()
                    }
                    
                    dataLoaded = true
                    // IMPORTANT: Render once and STOP
                    handCanvas.requestPaint()
                } else {
                }
            }
        }
        xhr.send()
    }
    
    // =========================================================================
    // CHECK IF POSITION IS PILL (using exact coordinates)
    // =========================================================================
    
    function isPillPosition(row, col) {
        // Check through arrays (Format 1)
        for (var i = 0; i < pillCoordRanges.length; i++) {
            var range = pillCoordRanges[i]
            if (range.row === row && col >= range.colStart && col <= range.colEnd) {
                return true
            }
        }
        
        // Check through pricise coordinates (Format 2)
        for (var j = 0; j < pillCoordPixels.length; j++) {
            var pixel = pillCoordPixels[j]
            if (pixel.row === row && pixel.col === col) {
                return true
            }
        }
        
        return false
    }
    
    // =========================================================================
    // STATIC CANVAS (RENDERS ONCE!)
    // =========================================================================
    
    Canvas {
        id: handCanvas
        anchors.fill: parent
        
        // Force proper size
        width: parent.width
        height: parent.height
        
        // NO TIMERS! NO ANIMATIONS! RENDER ONCE!
        
        onPaint: {
            
            var ctx = getContext("2d")
            if (!ctx) {
                return
            }
            
            ctx.clearRect(0, 0, width, height)
            
            if (!dataLoaded) {
                return
            }
            
            if (width <= 0 || height <= 0) {
                return
            }
            
            // Calculate scaling
            var maxWidth = 0
            for (var i = 0; i < asciiLines.length; i++) {
                var lineLen = asciiLines[i].length
                if (lineLen > maxWidth) maxWidth = lineLen
            }
            if (maxWidth === 0) maxWidth = 200

            var maxHeight = asciiLines.length

            var fontAspectRatio = 1.6
            var paddingFactor = 0.9
            var availableWidth = width * paddingFactor
            var availableHeight = height * paddingFactor

            var scaleByWidth = availableWidth / maxWidth
            var scaleByHeight = availableHeight / (maxHeight * fontAspectRatio)

            var scale = Math.min(scaleByWidth, scaleByHeight)

            var charWidth = Math.max(2, scale)
            var charHeight = Math.max(3, scale * fontAspectRatio)

            var totalWidth = maxWidth * charWidth
            var totalHeight = maxHeight * charHeight
            
            // Center with manual adjustment
            var offsetX = (width - totalWidth) / 2
            var offsetY = (height - totalHeight) / 2

            // FINAL VALUES - hands adjusted manually to the center !
            if (root.handType === "right") {
                // Right Hand (Left Monitor, red pill)
                offsetX = offsetX - width * 0.078
                offsetY = offsetY - height * 0.139
            } else {
                // Left Hand (Right Monitor, blue pill)
                offsetX = offsetX - width * 0.026
                offsetY = offsetY - height * 0.139
            }

            var fontFamily = monoFont.status === FontLoader.Ready ? monoFont.name : "monospace"
            ctx.font = Math.floor(charHeight) + "px '" + fontFamily + "'"
            ctx.textAlign = "left"
            ctx.textBaseline = "top"
            
            var drawnCount = 0
            
            // NO shadowBlur - too expensive
            ctx.shadowBlur = 0
            
            // Draw ASCII art
            for (var row = 0; row < asciiLines.length; row++) {
                var line = asciiLines[row]
                
                for (var col = 0; col < line.length; col++) {
                    var symbol = line.charAt(col)
                    
                    if (symbol === " " || symbol === "") continue
                    
                    var x = offsetX + col * charWidth + charWidth / 2
                    var y = offsetY + row * charHeight
                    
                    // Check if this is pill position (exact coordinates)
                    if (isPillPosition(row, col)) {
                        // Draw pill symbol in red/blue
                        ctx.fillStyle = root.pillColor.toString()
                        ctx.globalAlpha = 1.0
                        
                        ctx.fillText(symbol, x, y)
                        
                    } else {
                        // Draw normal hand character (green)
                        ctx.fillStyle = root.symbolColor.toString()
                        ctx.globalAlpha = 0.7
                        
                        ctx.fillText(symbol, x, y)
                    }
                    
                    drawnCount++
                }
            }
            
            ctx.globalAlpha = 1.0
            
        }
    }
    
    // =========================================================================
    // INITIALIZATION
    // =========================================================================
    
    Component.onCompleted: {       
        if (root.visible) {
            loadDelayTimer.start()
        }
    }
    
    Timer {
        id: loadDelayTimer
        interval: 50
        running: false
        repeat: false
        onTriggered: {
            loadASCII()
        }
    }
    
    onVisibleChanged: {
        if (visible && !dataLoaded) {
            loadASCII()
        }
    }
}