import AVFoundation

/// Loops silent audio so the app (and the proxy) stays alive in the background.
final class KeepAlive {
    private var player: AVAudioPlayer?

    init() {
        NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] note in
            guard let self, self.player != nil,
                  let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  AVAudioSession.InterruptionType(rawValue: raw) == .ended else { return }
            try? AVAudioSession.sharedInstance().setActive(true)
            self.player?.play()
        }
    }

    func start() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, options: [.mixWithOthers])
        try? session.setActive(true)
        if player == nil { player = try? AVAudioPlayer(data: Self.silentWav()) }
        player?.numberOfLoops = -1
        player?.volume = 0
        player?.play()
    }

    func stop() {
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    /// Long (30s), low-rate (8kHz 8-bit) silence minimizes wakeups at loop boundaries.
    private static func silentWav(seconds: Int = 30, rate: Int = 8000) -> Data {
        let samples = seconds * rate
        var d = Data()
        func u32(_ v: UInt32) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 4)) }
        func u16(_ v: UInt16) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 2)) }
        d.append("RIFF".data(using: .ascii)!); u32(UInt32(36 + samples))
        d.append("WAVEfmt ".data(using: .ascii)!); u32(16); u16(1); u16(1)
        u32(UInt32(rate)); u32(UInt32(rate)); u16(1); u16(8)
        d.append("data".data(using: .ascii)!); u32(UInt32(samples))
        d.append(Data(repeating: 0x80, count: samples))
        return d
    }
}
