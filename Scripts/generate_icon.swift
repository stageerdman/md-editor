// Draws the MiniMD app icon: a bold "M" with a small down-caret accent,
// on an indigo-to-navy gradient. Run via Scripts/generate_icon.sh, which
// rasterizes this at 1024x1024 and builds Resources/AppIcon.icns from it.
//
// The caret is deliberately smaller/lighter-weight than the M — an
// equal-weight "M" + full caret reads as the letter "V" next to it (i.e.
// "MV") at a glance, which defeats the point of a recognizable mark.
import AppKit

let size = 1024
let rect = NSRect(x: 0, y: 0, width: size, height: size)

let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()
guard let ctx = NSGraphicsContext.current?.cgContext else { fatalError("no ctx") }

let cornerRadius: CGFloat = CGFloat(size) * 0.223
let bgPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
bgPath.addClip()

let colors = [
    NSColor(calibratedRed: 0.42, green: 0.45, blue: 0.98, alpha: 1.0).cgColor, // indigo
    NSColor(calibratedRed: 0.16, green: 0.18, blue: 0.46, alpha: 1.0).cgColor  // deep navy
]
let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])

let glow = NSBezierPath(ovalIn: NSRect(x: -size / 4, y: size / 2, width: size, height: size))
NSColor.white.withAlphaComponent(0.06).setFill()
glow.fill()

let strokeWidth: CGFloat = CGFloat(size) * 0.088
let mWidth: CGFloat = CGFloat(size) * 0.46
let mHeight: CGFloat = CGFloat(size) * 0.40
let mOriginX = (CGFloat(size) - mWidth) / 2 - CGFloat(size) * 0.035
let mOriginY = (CGFloat(size) - mHeight) / 2 + CGFloat(size) * 0.035

let mPath = NSBezierPath()
mPath.lineWidth = strokeWidth
mPath.lineCapStyle = .round
mPath.lineJoinStyle = .round

let mLeft = mOriginX
let mRight = mOriginX + mWidth
let mTop = mOriginY + mHeight
let mBottom = mOriginY
let mMidY = mOriginY + mHeight * 0.34

mPath.move(to: NSPoint(x: mLeft, y: mBottom))
mPath.line(to: NSPoint(x: mLeft, y: mTop))
mPath.line(to: NSPoint(x: (mLeft + mRight) / 2, y: mMidY))
mPath.line(to: NSPoint(x: mRight, y: mTop))
mPath.line(to: NSPoint(x: mRight, y: mBottom))
NSColor.white.setStroke()
mPath.stroke()

let caretStroke: CGFloat = CGFloat(size) * 0.052
let caretSpan: CGFloat = CGFloat(size) * 0.16
let caretCenterX = mRight + CGFloat(size) * 0.06
let caretTopY = mOriginY + CGFloat(size) * 0.02
let caretBottomY = caretTopY - caretSpan * 0.62

let caretPath = NSBezierPath()
caretPath.lineWidth = caretStroke
caretPath.lineCapStyle = .round
caretPath.lineJoinStyle = .round
caretPath.move(to: NSPoint(x: caretCenterX - caretSpan / 2, y: caretTopY))
caretPath.line(to: NSPoint(x: caretCenterX, y: caretBottomY))
caretPath.line(to: NSPoint(x: caretCenterX + caretSpan / 2, y: caretTopY))
NSColor.white.withAlphaComponent(0.92).setStroke()
caretPath.stroke()

image.unlockFocus()

guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    fatalError("failed to render png")
}

let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon_1024.png"
try! png.write(to: URL(fileURLWithPath: outPath))
print("wrote \(outPath)")
