//
//  DrawingView.swift
//  TextDetection-CoreML
//
//  Created by GwakDoyoung on 21/02/2019.
//  Copyright © 2019 tucan9389. All rights reserved.
//

import UIKit
import Firebase

class DrawingView: UIView {

    public var imageSize: CGSize = .zero
    public var visionText: VisionText? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.clear(rect);
        guard let visionText = visionText else { return }
        
        let frameSize = self.bounds.size
        
        
        let blocks: [VisionTextBlock] = visionText.blocks
        print(blocks.count)
        let font = UIFont.systemFont(ofSize: 10)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.green
        ]
        
        for block in blocks {
            
            drawRect(ctx: ctx, rect: block.frame * (frameSize / imageSize),
                     color: UIColor(red: 0.0, green: 0.4, blue: 0.3, alpha: 0.12).cgColor)
            
            let lines: [VisionTextLine] = block.lines
            for line in lines {
                
                drawRect(ctx: ctx, rect: line.frame * (frameSize / imageSize),
                         color: UIColor(red: 0.7, green: 0.0, blue: 0.3, alpha: 0.18).cgColor)
                
                let elements: [VisionTextElement] = line.elements
                for element in elements {
                    
                    drawRect(ctx: ctx, rect: element.frame * (frameSize / imageSize),
                             color: UIColor(red: 0.3, green: 0.0, blue: 0.9, alpha: 0.23).cgColor)
                    
                    let text = element.text
                    text.draw(at: element.frame.origin * (frameSize / imageSize), withAttributes: attributes)
                }
            }
        }
    }
    
    private func drawLine(ctx: CGContext, from p1: CGPoint, to p2: CGPoint, color: CGColor) {
        ctx.setStrokeColor(color)
        ctx.setLineWidth(1.0)
        
        ctx.move(to: p1)
        ctx.addLine(to: p2)
        
        ctx.strokePath();
    }
    
    private func drawRect(ctx: CGContext, rect: CGRect, color: CGColor, fill: Bool = true) {
        let points: [CGPoint] = [
            rect.origin + CGSize(width: 0, height: 0),
            rect.origin + CGSize(width: rect.size.width, height: 0),
            rect.origin + CGSize(width: rect.size.width, height: rect.size.height),
            rect.origin + CGSize(width: 0, height: rect.size.height)
        ]
        drawPolygon(ctx: ctx, points: points, color: color, fill: fill)
    }
    
    private func drawPolygon(ctx: CGContext, points: [CGPoint], color: CGColor, fill: Bool = false) {
        if fill {
            ctx.setStrokeColor(UIColor.clear.cgColor)
            ctx.setFillColor(color)
            ctx.setLineWidth(0.0)
        } else {
            ctx.setStrokeColor(color)
            ctx.setLineWidth(1.0)
        }
        
        
        for i in 0..<points.count {
            if i == 0 {
                ctx.move(to: points[i])
            } else {
                ctx.addLine(to: points[i])
            }
        }
        if let firstPoint = points.first {
            ctx.addLine(to: firstPoint)
        }
        
        if fill {
            ctx.fillPath()
        } else {
            ctx.strokePath();
        }
    }
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func * (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x * right.width, y: left.y * right.height)
}

func / (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x / right.width, y: left.y / right.height)
}

func / (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width / right.width, height: left.height / right.height)
}

func * (left: CGRect, right: CGSize) -> CGRect {
    return CGRect(x: left.origin.x * right.width,
                  y: left.origin.y * right.height,
                  width: left.size.width * right.width,
                  height: left.size.height * right.height)
}

func + (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x + right.width, y: left.y + right.height)
}
