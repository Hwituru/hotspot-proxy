import SwiftUI

extension Color {
    static let signalOn = Color("SignalOn")
    static let signalWarn = Color("SignalWarn")
    static let signalOff = Color("SignalOff")
    static let heroTint = Color("HeroTint")
}

extension ProxySnapshot.Status {
    var color: Color {
        switch self {
        case .running: .signalOn
        case .noHotspot: .signalWarn
        case .stopped: .signalOff
        case .error: .red
        }
    }

    var symbol: String {
        switch self {
        case .running: "personalhotspot"
        case .noHotspot: "personalhotspot.slash"
        case .stopped: "pause.circle"
        case .error: "exclamationmark.triangle.fill"
        }
    }

    var title: String {
        switch self {
        case .running: "프록시 실행 중"
        case .noHotspot: "핫스팟 꺼짐"
        case .stopped: "프록시 꺼짐"
        case .error: "오류"
        }
    }

    var shortTitle: String {
        switch self {
        case .running: "실행 중"
        case .noHotspot: "핫스팟 꺼짐"
        case .stopped: "꺼짐"
        case .error: "오류"
        }
    }
}

enum Format {
    static func bytes(_ b: UInt64) -> String {
        let f = ByteCountFormatter()
        f.countStyle = .file
        f.allowsNonnumericFormatting = false
        return f.string(fromByteCount: Int64(clamping: b))
    }
}
