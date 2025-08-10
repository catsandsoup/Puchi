import SwiftUI
import AVFoundation

struct VoiceRecorderView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioRecorder = AudioRecorderManager()
    let onRecordingComplete: (Data?) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Recording status
                    VStack(spacing: 16) {
                        if audioRecorder.isRecording {
                            // Recording animation
                            RecordingAnimationView()
                            
                            Text("Recording...")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        } else if audioRecorder.hasRecording {
                            // Playback state
                            VStack(spacing: 16) {
                                Image(systemName: "waveform.circle.fill")
                                    .font(.system(size: 64))
                                    .foregroundColor(.pink)
                                
                                Text("Voice Note Ready")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                // Recording duration
                                Text(formatTime(audioRecorder.recordingDuration))
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                        } else {
                            // Ready to record state
                            VStack(spacing: 16) {
                                Image(systemName: "waveform")
                                    .font(.system(size: 64))
                                    .foregroundColor(.gray)
                                
                                Text("Ready to Record")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("Tap the microphone to start recording your voice note")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Controls
                    VStack(spacing: 24) {
                        // Main record/stop button
                        Button(action: {
                            if audioRecorder.isRecording {
                                audioRecorder.stopRecording()
                            } else {
                                audioRecorder.startRecording()
                            }
                        }) {
                            ZStack {
                                Group {
                                    if audioRecorder.isRecording {
                                        Circle()
                                            .fill(Color.red)
                                    } else {
                                        Circle()
                                            .fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    }
                                }
                                .frame(width: 80, height: 80)
                                .shadow(color: (audioRecorder.isRecording ? Color.red : Color.pink).opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(!audioRecorder.hasPermission)
                        
                        // Secondary controls
                        if audioRecorder.hasRecording && !audioRecorder.isRecording {
                            HStack(spacing: 32) {
                                // Play/Pause button
                                Button(action: {
                                    if audioRecorder.isPlaying {
                                        audioRecorder.pausePlayback()
                                    } else {
                                        audioRecorder.startPlayback()
                                    }
                                }) {
                                    Image(systemName: audioRecorder.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.pink)
                                }
                                
                                // Delete recording
                                Button(action: {
                                    audioRecorder.deleteRecording()
                                }) {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        // Permission message
                        if !audioRecorder.hasPermission {
                            Text("Microphone access is required to record voice notes")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
            }
            .navigationTitle("Voice Note")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        audioRecorder.cleanup()
                        dismiss()
                    }
                    .foregroundColor(.pink)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        if let recordingData = audioRecorder.getRecordingData() {
                            onRecordingComplete(recordingData)
                        } else {
                            onRecordingComplete(nil)
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.pink)
                    .disabled(!audioRecorder.hasRecording)
                }
            }
        }
        .onAppear {
            audioRecorder.requestPermission()
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct RecordingAnimationView: View {
    @State private var animationAmount = 1.0
    
    var body: some View {
        Image(systemName: "mic.fill")
            .font(.system(size: 64))
            .foregroundColor(.red)
            .scaleEffect(animationAmount)
            .animation(
                .easeInOut(duration: 0.8)
                .repeatForever(autoreverses: true),
                value: animationAmount
            )
            .onAppear {
                animationAmount = 1.2
            }
    }
}

// MARK: - Audio Recorder Manager
class AudioRecorderManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var hasRecording = false
    @Published var hasPermission = false
    @Published var recordingDuration: TimeInterval = 0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingURL: URL?
    private var timer: Timer?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    func requestPermission() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    self.hasPermission = granted
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    self.hasPermission = granted
                }
            }
        }
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: [])
            if #available(iOS 17.0, *) {
                hasPermission = AVAudioApplication.shared.recordPermission == .granted
            } else {
                hasPermission = audioSession.recordPermission == .granted
            }
        } catch {
            print("Failed to setup audio session: \(error)")
            hasPermission = false
        }
    }
    
    func startRecording() {
        guard hasPermission else { return }
        
        // Stop any existing playback
        audioPlayer?.stop()
        isPlaying = false
        
        // Setup audio session for recording
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session for recording: \(error)")
            return
        }
        
        // Create a unique filename in Media directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let mediaPath = documentsPath.appendingPathComponent("Media")
        
        // Create Media directory if needed
        try? FileManager.default.createDirectory(at: mediaPath, withIntermediateDirectories: true)
        
        recordingURL = mediaPath.appendingPathComponent("voice_note_\(Date().timeIntervalSince1970).m4a")
        
        guard let url = recordingURL else { return }
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 22050.0, // Lower sample rate to reduce file size
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue // Medium quality to reduce file size
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            recordingDuration = 0
            
            // Start timer for duration
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                DispatchQueue.main.async {
                    self.recordingDuration = self.audioRecorder?.currentTime ?? 0
                }
            }
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        isRecording = false
        hasRecording = true
    }
    
    func startPlayback() {
        guard let url = recordingURL else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Failed to start playback: \(error)")
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func deleteRecording() {
        audioPlayer?.stop()
        audioRecorder?.stop()
        
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        
        recordingURL = nil
        hasRecording = false
        isPlaying = false
        recordingDuration = 0
    }
    
    func getRecordingData() -> Data? {
        guard let url = recordingURL else { return nil }
        return try? Data(contentsOf: url)
    }
    
    func cleanup() {
        audioPlayer?.stop()
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
        
        // Only delete if the recording hasn't been saved to an entry
        // The MediaItem will handle file cleanup when needed
        recordingURL = nil
        isRecording = false
        isPlaying = false
        hasRecording = false
        recordingDuration = 0
    }
}

// MARK: - Audio Recorder Delegate
extension AudioRecorderManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isRecording = false
            self.hasRecording = flag
        }
    }
}

// MARK: - Audio Player Delegate
extension AudioRecorderManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}

#Preview {
    VoiceRecorderView { data in
        print("Recording completed with data: \(data != nil ? "✓" : "✗")")
    }
    .preferredColorScheme(.dark)
}