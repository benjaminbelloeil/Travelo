//
//  StressReliefView.swift
//  Travelo
//
//  Created by Dawar Hasnain on 16/10/25.
//

import SwiftUI
import AVFoundation
import Speech

// MARK: - Supporting Models

struct Song: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let fileName: String
}

struct MoodColor: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String       // "Happy", "Sad", etc.
    let key: String        // key in moodSongs dictionary
    let color: Color
}

struct ItalianPhrase: Identifiable, Equatable{
    let id = UUID()
    let phrase: String
    let translation: String
}

// MARK: - Main View

struct StressReliefView: View {
    // MARK: - Variable Declarations
    
    // MARK: - Audio & Music Playback
    @State private var isPlaying = false                  // Whether a background song is currently playing
    @State private var audioPlayer: AVAudioPlayer?        // Player instance for ambient or mood-based songs
    @State private var currentSong: Song? = nil           // Currently selected song metadata

    // MARK: - Mood & Visual State
    @State private var currentColor: Color = Color("Primary").opacity(1)  // Active UI color matching the selected mood
    @State private var selectedMood: MoodColor? = nil                       // User’s currently chosen mood (via slider)

    // MARK: - Popup & Phrase Handling
    @State private var showPhrasePopup = false            // Controls visibility of the Italian phrase popup
    @State private var currentPhrase: ItalianPhrase? = nil// Currently displayed Italian phrase data (text + translation)
    @State private var phraseTimer: DispatchWorkItem? = nil// Timer controlling when the phrase popup appears
    @State private var speechSynthesizer = AVSpeechSynthesizer() // Used to pronounce Italian phrases aloud

    // MARK: - UI / Miscellaneous States
    @State private var isTutorial = false                 // Whether the tutorial or onboarding overlay is visible
    @State private var tutorialStep = 0                   //

    // MARK: - Speech Recognition
    @State private var isRecording = false                // Indicates whether speech input is actively being captured
    @State private var recognizedText: String = ""        // Stores the recognized text from the user’s speech
    @State private var recognitionResult: Bool? = nil     // Feedback flag: true = correct, false = incorrect, nil = not evaluated
    @State private var recordingTimer: Timer? = nil       // Timer to auto-stop speech recognition after a few seconds

    // MARK: - Speech Recognition Engine Components
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "it-IT"))!  // Italian language recognizer
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?           // Live audio input request
    @State private var recognitionTask: SFSpeechRecognitionTask?                            // Active recognition task handler
    private let audioEngine = AVAudioEngine()                                               // Core audio engine for mic input

    
    @State private var selectedTab = 0

    // MARK: - Mood Library
    let moods: [MoodColor] = [
        MoodColor(name: "Happy",     key: "Happy",     color: Color(hex: "FFD966")),
        MoodColor(name: "Sad",       key: "Sad",       color: Color(hex: "80A6E6")),
        MoodColor(name: "Energetic", key: "Energetic", color: Color(hex: "FF7366"))
    ]

    //MARK: - Mood-based Sound Library
    let moodSongs: [String: [Song]] = [
        "Happy": [
            Song(title: "Sunshine Smile", fileName: "happy-1"),
            Song(title: "Morning Energy", fileName: "happy-2")
        ],
        "Sad": [
            Song(title: "Cool Down", fileName: "anxiety-1"),
            Song(title: "Cool Down #2", fileName: "anxiety-2")
        ],
        "Energetic": [
            Song(title: "Power Pulse", fileName: "energetic-1"),
            Song(title: "Power Pulse #2", fileName: "energetic-2")
        ]
    ]
    
    //MARK: - Tutorial Texts
    private let tutorialSteps: [String] = [
        "Welcome to the Travelo Stress relief space.",
        "Each color represents a mood. Choose the one that matches your feeling.",
        "Tap the glowing circle to begin playing a calming track.",
        "After a few moments, you’ll see an Italian phrase — repeat it out loud to learn while you relax.",
        "You’ll get friendly feedback on your pronunciation. Let’s begin!"
    ]

    
    // MARK: - Phrase Library
    let moodPhrases: [String: [ItalianPhrase]] = [
        "Happy": [
            ItalianPhrase(phrase: "Che bella giornata!", translation: "What a beautiful day!"),
            ItalianPhrase(phrase: "Mi sento pieno di energia!", translation: "I feel full of energy!"),
            ItalianPhrase(phrase: "Sono così felice oggi!", translation: "I’m so happy today!"),
            ItalianPhrase(phrase: "È andato tutto per il meglio!", translation: "Everything went perfectly!"),
            ItalianPhrase(phrase: "Adoro questo momento!", translation: "I love this moment!"),
            ItalianPhrase(phrase: "Ho una gran voglia di sorridere!", translation: "I really feel like smiling!"),
            ItalianPhrase(phrase: "È bello essere qui!", translation: "It’s nice to be here!"),
            ItalianPhrase(phrase: "Hai un sorriso contagioso!", translation: "You have a contagious smile!"),
            ItalianPhrase(phrase: "La vita è bella!", translation: "Life is beautiful!"),
            ItalianPhrase(phrase: "Non potrei chiedere di più!", translation: "I couldn’t ask for more!")
        ],
        "Sad": [
            ItalianPhrase(phrase: "Va tutto bene?", translation: "Is everything okay?"),
            ItalianPhrase(phrase: "Mi sento un po’ giù oggi.", translation: "I’m feeling a bit down today."),
            ItalianPhrase(phrase: "Ho solo bisogno di un abbraccio.", translation: "I just need a hug."),
            ItalianPhrase(phrase: "Mi manchi.", translation: "I miss you."),
            ItalianPhrase(phrase: "A volte va così.", translation: "Sometimes it just goes that way."),
            ItalianPhrase(phrase: "Non è stato un giorno facile.", translation: "It hasn’t been an easy day."),
            ItalianPhrase(phrase: "Vorrei solo un po’ di silenzio.", translation: "I’d like a bit of quiet."),
            ItalianPhrase(phrase: "Ho bisogno di stare solo.", translation: "I need to be alone."),
            ItalianPhrase(phrase: "Mi sento perso nei miei pensieri.", translation: "I feel lost in my thoughts."),
            ItalianPhrase(phrase: "Domani andrà meglio.", translation: "Tomorrow will be better.")
        ],
        "Energetic": [
            ItalianPhrase(phrase: "Forza!", translation: "Come on!"),
            ItalianPhrase(phrase: "Ce la posso fare!", translation: "I can do it!"),
            ItalianPhrase(phrase: "Dai, muoviamoci!", translation: "Come on, let’s move!"),
            ItalianPhrase(phrase: "Sono pronto a tutto!", translation: "I’m ready for anything!"),
            ItalianPhrase(phrase: "Andiamo a fare qualcosa!", translation: "Let’s go do something!"),
            ItalianPhrase(phrase: "Niente può fermarmi oggi!", translation: "Nothing can stop me today!"),
            ItalianPhrase(phrase: "Ho una carica incredibile!", translation: "I have incredible energy!"),
            ItalianPhrase(phrase: "Facciamolo!", translation: "Let’s do it!"),
            ItalianPhrase(phrase: "Sono al massimo!", translation: "I’m at my best!"),
            ItalianPhrase(phrase: "Il momento è adesso!", translation: "The moment is now!")
        ]
    ]


    // MARK: - UI
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header section - matching Home/Guide style
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Find Your Calm")
                                    .font(.system(size: 28, weight: .heavy))
                                    .foregroundColor(.black)
                                
                                Text("Meditate and learn Italian phrases")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Main meditation section
                        VStack(spacing: 40) {
                            // Meditation Orb - made bigger
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            gradient: Gradient(colors: [currentColor.opacity(0.4), currentColor.opacity(0.1)]),
                                            center: .center,
                                            startRadius: 10,
                                            endRadius: 140
                                        )
                                    )
                                    .frame(width: 280, height: 280)
                                    .shadow(color: currentColor.opacity(0.2), radius: 15)
                                    .overlay(
                                        Button(action: playSoundForCurrentMood) {
                                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                                .font(.system(size: 42))
                                                .foregroundColor(.white)
                                                .shadow(color: .black.opacity(0.3), radius: 5)
                                        }
                                    )
                                    .animation(.easeInOut(duration: 0.5), value: currentColor)
                            }
                            
                            // Song name display - with proper spacing
                            VStack(spacing: 8) {
                                if let song = currentSong {
                                    Text("Now Playing")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Text(song.title)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.black)
                                        .animation(.easeInOut(duration: 0.3), value: song.title)
                                }
                            }
                            .frame(minHeight: 50) // Reserve space to prevent layout shifts
                            
                            // Mood selection section - in a card
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text("Select your mood")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                
                                VStack(spacing: 24) {
                                    // Mood labels - properly aligned with slider positions
                                    HStack {
                                        Text("Happy")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(selectedMood?.key == "Happy" ? moods[0].color : .gray)
                                            .frame(width: 60, alignment: .leading) // Fixed width, left aligned
                                        
                                        Spacer()
                                        
                                        Text("Sad")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(selectedMood?.key == "Sad" ? moods[1].color : .gray)
                                            .frame(alignment: .center)
                                        
                                        Spacer()
                                        
                                        Text("Energetic")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(selectedMood?.key == "Energetic" ? moods[2].color : .gray)
                                            .frame(width: 80, alignment: .trailing) // Fixed width, right aligned
                                    }
                                    .padding(.horizontal, 12) // Match slider padding
                                    .animation(.easeInOut(duration: 0.3), value: selectedMood)
                                    
                                    // Improved slider - properly aligned
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            // Base track - transparent
                                            Capsule()
                                                .fill(Color.black.opacity(0.1))
                                                .frame(height: 4)
                                            
                                            // Active track (up to current mood) - transparent
                                            Capsule()
                                                .fill((selectedMood?.color ?? moods[0].color).opacity(0.3))
                                                .frame(width: knobXPosition(geo: geo), height: 4)
                                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedMood)
                                            
                                            // Knob - more prominent
                                            Circle()
                                                .fill(selectedMood?.color ?? moods[0].color)
                                                .frame(width: 24, height: 24)
                                                .offset(x: knobXPosition(geo: geo) - 12, y: 0)
                                                .shadow(color: (selectedMood?.color ?? moods[0].color).opacity(0.3), radius: 4)
                                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedMood)
                                                .gesture(
                                                    DragGesture(minimumDistance: 0)
                                                        .onChanged { value in
                                                            let stepWidth = geo.size.width / CGFloat(moods.count - 1)
                                                            let index = Int(round(value.location.x / stepWidth))

                                                            if index >= 0 && index < moods.count {
                                                                let newMood = moods[index]

                                                                if newMood != selectedMood {
                                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                                        selectedMood = newMood
                                                                        currentColor = newMood.color
                                                                    }

                                                                    // If playing, smoothly transition to new song
                                                                    if isPlaying {
                                                                        if let songs = moodSongs[newMood.key],
                                                                           let randomSong = songs.randomElement() {
                                                                            currentSong = randomSong
                                                                            playSound(named: randomSong.fileName)
                                                                            // Cancel existing phrase timer and start new one
                                                                            phraseTimer?.cancel()
                                                                            startPhraseTimer()
                                                                        }
                                                                    }

                                                                    // Haptic feedback
                                                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                                }
                                                            }
                                                        }
                                                )
                                        }
                                    }
                                    .frame(height: 40)
                                    .padding(.horizontal, 12)
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.gray.opacity(0.05))
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100) // Space for bottom navigation
                    }
                }
                .navigationBarHidden(true)
                .background(Color.white)
            }
            .onAppear {
                // Set default mood to Happy
                if selectedMood == nil {
                    selectedMood = moods[0] // Happy
                    currentColor = moods[0].color
                }
            }
            .onDisappear {
                // Stop music when leaving the tab
                if isPlaying {
                    audioPlayer?.stop()
                    audioPlayer = nil
                    isPlaying = false
                    currentSong = nil
                    phraseTimer?.cancel()
                }
            }
            
            // Fixed popup with darker background
            if showPhrasePopup {
                Color.black.opacity(0.7) // Much darker background dimmer
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(1)

                modernPopupView // Updated popup design
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(2)
            }
            
            // MARK: - Tutorial Overlay with Apple-like gray background
            if isTutorial {
                ZStack {
                    // Apple-like gray background
                    Color.gray.opacity(0.9)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .zIndex(2)

                    // Centered popup card
                    VStack(spacing: 0) {
                        // Tutorial content card - smaller popup style
                        VStack(spacing: 0) {
                            
                            // Main content area - properly centered
                            VStack(spacing: 0) {
                                Spacer() // This pushes content to center
                                
                                VStack(spacing: 16) {
                                    // Show icon for all steps
                                    Image(systemName: getCurrentTutorialIcon())
                                        .font(.system(size: 40))
                                        .foregroundColor(tutorialStep == 0 ? .green : .blue)
                                    
                                    VStack(spacing: 8) {
                                        Text(getCurrentTutorialTitle())
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)
                                        
                                        Text(getCurrentTutorialDescription())
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(nil)
                                    }
                                    .padding(.horizontal, 24)
                                }
                                
                                Spacer() // This keeps content centered
                            }
                            .frame(height: 180) // Consistent height for all steps
                            
                            // Progress indicator
                            HStack(spacing: 8) {
                                ForEach(0..<5) { index in
                                    Circle()
                                        .fill(index == tutorialStep ? Color.blue : Color.gray.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                        .animation(.easeInOut(duration: 0.3), value: tutorialStep)
                                }
                            }
                            .padding(.vertical, 16)
                            
                            // Button area
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    if tutorialStep < 4 { // 5 steps total (0-4)
                                        tutorialStep += 1
                                    } else {
                                        withAnimation(.easeInOut) {
                                            isTutorial = false
                                        }
                                    }
                                }
                            } label: {
                                Text(tutorialStep == 4 ? "Start Meditating" : "Continue")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.blue)
                                    .cornerRadius(22)
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }
                        .frame(width: 340, height: 380) // Slightly bigger for better content fit
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                        )
                    }
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(3)
                }
            }
        }
        .animation(.easeInOut, value: showPhrasePopup)
        .onAppear {
            if !UserDefaults.standard.bool(forKey: "tutorialShown") {
                showTutorial()
                UserDefaults.standard.set(true, forKey: "tutorialShown")
            }
        }

    }
    
    private var modernPopupView: some View {
        VStack(spacing: 24) {
            if let phrase = currentPhrase {
                VStack(spacing: 20) {
                    // Italian phrase
                    Text(phrase.phrase)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Translation
                    Text(phrase.translation)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    // Action buttons in oval cards
                    HStack(spacing: 16) {
                        // Listen button
                        Button {
                            speakPhrase(phrase.phrase)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 16))
                                Text("Listen")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(20)
                        }

                        // Speak button
                        Button {
                            requestSpeechPermissions { granted in
                                guard granted else { return }
                                if isRecording { stopRecording() }
                                else if let phrase = currentPhrase?.phrase { startRecording(for: phrase) }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: isRecording ? "mic.fill" : "mic")
                                    .font(.system(size: 16))
                                Text(isRecording ? "Listening..." : "Speak")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(isRecording ? .red : .green)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background((isRecording ? Color.red : Color.green).opacity(0.1))
                            .cornerRadius(20)
                        }
                    }

                    // Feedback result
                    if let result = recognitionResult {
                        HStack(spacing: 8) {
                            Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(result ? .green : .red)
                            Text(result ? "Great job!" : "Try again!")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(result ? .green : .red)
                        }
                        .padding(.top, 8)
                    }
                    
                    // Continue button
                    Button("Continue") {
                        withAnimation {
                            recognitionResult = nil
                            recognizedText = ""
                            showPhrasePopup = false
                            audioPlayer?.play()
                            isPlaying = true
                        }
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(25)
                }
                .padding(30)
                .frame(maxWidth: 350)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding()
            }
        }
    }
    
    // Helper function to start phrase timer
    private func startPhraseTimer() {
        let randomDelay = Double.random(in: 1...5)
        let workItem = DispatchWorkItem {
            showRandomPhraseForCurrentMood()
        }
        phraseTimer = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay, execute: workItem)
    }
    
    private var popupView: some View {
        VStack(spacing: 20) {
            if let phrase = currentPhrase {
                VStack(spacing: 16) {
                    ScrollView {
                        Text(phrase.phrase)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text(phrase.translation)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Replay pronunciation
                    Button {
                        speakPhrase(phrase.phrase)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "speaker.wave.2.fill")
                            Text("Tap to Listen")
                        }
                        .font(.subheadline)
                        .foregroundColor(.black)
                    }

                    // Speak the Italian Phrases
                    Button {
                        requestSpeechPermissions { granted in
                            guard granted else { return }
                            if isRecording { stopRecording() }
                            else if let phrase = currentPhrase?.phrase { startRecording(for: phrase) }
                        }
                    } label: {
                        Label(isRecording ? "Listening..." : "Speak Phrase",
                              systemImage: isRecording ? "mic.fill" : "mic")
                            .foregroundColor(isRecording ? .red : .blue)
                    }

                    .padding(.bottom, 4)

                    // Feedback result
                    if let result = recognitionResult {
                        if result {
                            Label("Well done!", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.subheadline)
                        } else {
                            Label("Try again!", systemImage: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }
                    }

                    
                    // Continue button
                    Button("Continue") {
                        withAnimation {
                            recognitionResult = nil
                            recognizedText = ""
                            
                            showPhrasePopup = false
                            audioPlayer?.play()
                            isPlaying = true
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 30)
                    .background(Color("Primary").opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .frame(width: 300, height: 280) // fixed size for consistency
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .shadow(radius: 10)
            }
        }
    }
    
    // MARK: - Audio Session Setup
    // Prepares the AVAudioSession for recording mode before starting speech recognition.
    // Called once before each recording begins.
    
    private func prepareAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Permissions
    // Requests both Speech Recognition and Microphone access from the user.
    // The result is passed to a completion handler as a Bool (granted or not).
    
    func requestSpeechPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { speechStatus in
            AVAudioSession.sharedInstance().requestRecordPermission { micGranted in
                DispatchQueue.main.async {
                    let allowed = (speechStatus == .authorized) && micGranted
                    if !allowed {
                        print("Speech or mic not authorized: \(speechStatus), mic=\(micGranted)")
                    }
                    completion(allowed)
                }
            }
        }
    }

    // MARK: - Speech Recognition Lifecycle

    // Begins speech recognition for the given Italian phrase.
    // Configures the audio engine, installs tap, starts recognition task, and triggers auto-stop timer.
    
    private func startRecording(for phrase: String) {
        prepareAudioSession()
        recognitionResult = nil
        recognizedText = ""
        isRecording = true

        // Stop if already running
        if audioEngine.isRunning {
            stopRecording()
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { return }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("Could not start audio engine: \(error.localizedDescription)")
            isRecording = false
            return
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result {
                recognizedText = result.bestTranscription.formattedString
            }

            if error != nil || (result?.isFinal ?? false) {
                stopRecording()
                checkPronunciation(for: phrase)
            }
        }

        // Auto-stop after 4 seconds
        recordingTimer?.invalidate()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
            print("Auto-stopping recording after 4 seconds.")
            stopRecording()
            checkPronunciation(for: phrase)
        }

        print("Listening for: \(phrase)")
    }
    
    // Stops the active recording session and recognition task, restoring audio playback afterwards.
    
    private func stopRecording() {
        guard audioEngine.isRunning else { return }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil

        isRecording = false
        print("Recording stopped.")
        
        restoreAudioSessionForPlayback()
    }

    
    //MARK: - Check Pronounciation
    // Uses Levenshtein distance to calculate similarity percentage.
    
    private func checkPronunciation(for phrase: String) {
        let normalizedTarget = phrase.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        let normalizedUser = recognizedText.lowercased().folding(options: .diacriticInsensitive, locale: .current)

        // Basic similarity check (you can enhance this later)
        let distance = levenshteinDistance(normalizedTarget, normalizedUser)
        let accuracy = 1 - (Double(distance) / Double(max(normalizedTarget.count, normalizedUser.count)))

        recognitionResult = accuracy > 0.7 // pass if similarity > 70%
    }
    
    private func levenshteinDistance(_ lhs: String, _ rhs: String) -> Int {
        let lhsChars = Array(lhs)
        let rhsChars = Array(rhs)
        let m = lhsChars.count
        let n = rhsChars.count
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m { dp[i][0] = i }
        for j in 0...n { dp[0][j] = j }

        for i in 1...m {
            for j in 1...n {
                if lhsChars[i - 1] == rhsChars[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] = min(
                        dp[i - 1][j - 1] + 1, // substitution
                        dp[i][j - 1] + 1,     // insertion
                        dp[i - 1][j] + 1      // deletion
                    )
                }
            }
        }
        return dp[m][n]
    }

    // MARK: - Speech Output
    // Uses AVSpeechSynthesizer to pronounce an Italian phrase aloud at a comfortable rate.
    
    private func speakPhrase(_ phrase: String) {
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
        utterance.rate = 0.45    // comfortable speed (0.0 – 1.0)
        utterance.pitchMultiplier = 1.0
        speechSynthesizer.stopSpeaking(at: .immediate)
        speechSynthesizer.speak(utterance)
    }

    // MARK: - Audio Playback
    // Plays or pauses a mood-based or random song, and triggers Italian phrase popup timer.
    
    private func playSoundForCurrentMood() {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
            phraseTimer?.cancel() // stop existing timer if paused
            return
        }

        // Select a song from mood or all
        let songToPlay: Song?
        if let mood = selectedMood, let songs = moodSongs[mood.key] {
            songToPlay = songs.randomElement()
        } else {
            songToPlay = moodSongs.flatMap { $0.value }.randomElement()
        }

        guard let selectedSong = songToPlay else { return }

        currentSong = selectedSong
        playSound(named: selectedSong.fileName)
        isPlaying = true

        // Start phrase timer (20–30 seconds)
        let randomDelay = Double.random(in: 1...5)
        let workItem = DispatchWorkItem {
            showRandomPhraseForCurrentMood()
        }
        phraseTimer = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay, execute: workItem)
    }
    
    // Retrieves a random Italian phrase corresponding to the current mood.
    // Pauses playback, shows popup, and plays spoken phrase via TTS.
    
    private func showRandomPhraseForCurrentMood()
    {
        guard let mood = selectedMood,
              let phrases = moodPhrases[mood.key],
              !phrases.isEmpty else { return }
        
        currentPhrase = phrases.randomElement()
        
        audioPlayer?.pause()
        isPlaying = false
        
        withAnimation{
            showPhrasePopup = true
        }
        
        if let phrase = currentPhrase?.phrase {
            speakPhrase(phrase)
        }
        
    }
    

    // Loads and plays an MP3 file from the app bundle using AVAudioPlayer.
    
    private func playSound(named name: String) {
        if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error playing \(name): \(error.localizedDescription)")
            }
        } else {
            print("File \(name).mp3 not found in bundle.")
        }
    }
    
    // Restores the AVAudioSession category back to playback after a recording finishes.
    // Re-enables music/audio output.
    
    private func restoreAudioSessionForPlayback() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            print("Audio session restored for playback")
        } catch {
            print("Could not restore audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - UI Helpers (Mood Slider)
    // Calculates the horizontal knob position for the custom mood slider based on the selected mood index.
    
    private func knobXPosition(geo: GeometryProxy) -> CGFloat {
        guard let selectedMood = selectedMood,
              let index = moods.firstIndex(of: selectedMood)
        else { return 0 }
        let stepWidth = geo.size.width / CGFloat(moods.count - 1)
        return CGFloat(index) * stepWidth
    }
    
    // MARK: - Tutorial Helpers
    private let tutorialData: [(icon: String, title: String, description: String)] = [
        ("leaf", "Welcome to Calm", "Your meditation sanctuary for relaxation and Italian language learning."),
        ("slider.horizontal.3", "Choose your emotional state", "Use the mood slider to match your current feelings. Happy, Sad, or Energetic - each has unique calming music."),
        ("play.circle", "Start your meditation session", "Tap the large meditation circle to begin playing music tailored to your selected mood and emotional needs."),
        ("message", "Practice Italian phrases mindfully", "During your session, Italian phrases will appear. This combines meditation with gentle language learning."),
        ("checkmark.circle", "Get pronunciation feedback", "Speak the phrases aloud to practice pronunciation and receive helpful feedback on your Italian speaking skills.")
    ]
    
    private func getCurrentTutorialIcon() -> String {
        tutorialData[tutorialStep].icon
    }
    
    private func getCurrentTutorialTitle() -> String {
        tutorialData[tutorialStep].title
    }
    
    private func getCurrentTutorialDescription() -> String {
        tutorialData[tutorialStep].description
    }
    
    //MARK: - Show a Tutorial Screen for new user

    private func showTutorial() {
        withAnimation(.easeInOut) {
            isTutorial = true
            tutorialStep = 0
        }
    }

    private func advanceTutorial() {
        if tutorialStep < 4 { // 5 steps total (0-4)
            tutorialStep += 1
        } else {
            withAnimation(.easeInOut) {
                isTutorial = false
            }
        }
    }

}

#Preview {
    StressReliefView()
}
