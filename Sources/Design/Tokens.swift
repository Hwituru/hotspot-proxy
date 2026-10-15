import SwiftUI

enum Space {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

enum Radius {
    static let card: CGFloat = 22
    static let tile: CGFloat = 16
}

enum Motion {
    static let micro = Animation.snappy(duration: 0.12)
    static let standard = Animation.smooth(duration: 0.3)
}
