import AVFoundation
import Foundation

@MainActor
final class VoiceMemoRecorder: NSObject, ObservableObject {
    @Published private(set) var isRecording = false
    @Published private(set) var data: Data?
    @Published private(set) var errorMessage: String?
    private var recorder: AVAudioRecorder?
    private var fileURL: URL?

    var hasRecording: Bool { data != nil }

    func load(_ data: Data?) {
        guard !isRecording else { return }
        self.data = data
    }

    func start() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("voice-\(UUID().uuidString).m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.record()
            self.recorder = recorder
            fileURL = url
            errorMessage = nil
            isRecording = true
        } catch {
            errorMessage = "无法开始录音，请检查麦克风权限。"
        }
    }

    func stop() {
        recorder?.stop()
        isRecording = false
        if let fileURL { data = try? Data(contentsOf: fileURL) }
        recorder = nil
    }

    func remove() {
        if isRecording { stop() }
        data = nil
        errorMessage = nil
    }
}
