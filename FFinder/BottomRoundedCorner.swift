import SwiftUI

struct BottomRoundedCorner: Shape {
    var radius: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        // Start at top-left corner
        path.move(to: CGPoint(x: 0, y: 0))
        
        // Draw top and right sides
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height - radius))
        
        // Draw bottom-right corner
        path.addArc(center: CGPoint(x: width - radius, y: height - radius),
                    radius: radius,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)
        
        // Draw bottom and left sides
        path.addLine(to: CGPoint(x: radius, y: height))
        
        // Draw bottom-left corner
        path.addArc(center: CGPoint(x: radius, y: height - radius),
                    radius: radius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: 0))
        return path
    }
}
