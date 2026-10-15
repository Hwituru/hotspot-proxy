import Foundation

/// 앱 ↔ 위젯이 App Group으로 공유하는 프록시 상태 스냅샷.
/// 앱은 상태가 바뀔 때 save() 후 WidgetCenter를 갱신하고, 위젯은 load()로 읽기만 한다.
struct ProxySnapshot: Codable, Equatable {
    enum Status: String, Codable {
        case running      // 리스너 준비 완료, 핫스팟 켜짐
        case noHotspot    // 프록시는 켜졌지만 핫스팟(bridge 인터페이스)이 없음
        case stopped      // 사용자가 끔
        case error        // 리스너 실패
    }

    var status: Status
    var hotspotIP: String?
    var port: Int
    var connections: Int
    var bytes: UInt64
    var errorMessage: String?
    var updatedAt: Date

    /// 다른 기기에 입력할 "IP:포트". 핫스팟이 없으면 nil.
    var endpoint: String? { hotspotIP.map { "\($0):\(port)" } }

    static let placeholder = ProxySnapshot(status: .running, hotspotIP: "172.20.10.1", port: 8080,
                                           connections: 3, bytes: 48_300_000, errorMessage: nil, updatedAt: .now)
    static let empty = ProxySnapshot(status: .stopped, hotspotIP: nil, port: 8080,
                                     connections: 0, bytes: 0, errorMessage: nil, updatedAt: .distantPast)
}

enum SharedStore {
    static let appGroup = "group.com.indoyoon.hotspotproxy"
    static let widgetKind = "HotspotProxyStatus"
    private static let key = "snapshot.v1"

    static var defaults: UserDefaults { UserDefaults(suiteName: appGroup) ?? .standard }

    static func load() -> ProxySnapshot {
        guard let data = defaults.data(forKey: key),
              let s = try? JSONDecoder().decode(ProxySnapshot.self, from: data) else { return .empty }
        return s
    }

    static func save(_ s: ProxySnapshot) {
        guard let data = try? JSONEncoder().encode(s) else { return }
        defaults.set(data, forKey: key)
    }
}

/// 위젯/외부에서 앱을 여는 딥링크. hotspotproxy://open | hotspotproxy://start | hotspotproxy://stop | hotspotproxy://copy
enum DeepLink: String {
    case open, start, stop, toggle, copy
    var url: URL { URL(string: "hotspotproxy://\(rawValue)")! }
    init?(url: URL) {
        guard url.scheme == "hotspotproxy", let v = DeepLink(rawValue: url.host ?? "open") else { return nil }
        self = v
    }
}
