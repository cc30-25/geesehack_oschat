import SwiftUI
import Speech
import AVFoundation
import Foundation

struct HomeView: View {
    @State private var userInput: String = ""
    @State private var isRecording: Bool = false
    @State private var recognizedText: String = ""
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(recognizedText.isEmpty ? "What do you want to do?" : recognizedText)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Displaying the recognized speech or the user input
                Text("Recognized Text: \(recognizedText)")
                    .padding()
                    .foregroundColor(.gray)
                
                // TextField for typed input (fallback if speech recognition fails or isn't used)
                TextField("Enter your request...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Microphone button for voice input
                Button(action: {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                    
                    isRecording.toggle()
                }) {
                    Image(systemName: isRecording ? "mic.slash.fill" : "mic.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(isRecording ? .red : .blue)
                }
                .padding()

                // Next button for navigation
                NavigationLink(destination: DetailsView(userInput: userInput)) {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(userInput.isEmpty) // Disable button if input is empty
            }
            .padding()
            .onAppear {
                requestSpeechRecognitionPermission()
            }
        }
    }

    // Request authorization for speech recognition
    func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus != .authorized {
                    print("Speech recognition not authorized")
                }
            }
        }
    }

    // Start recording user voice
    func startRecording() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("Speech recognizer not available")
            return
        }

        // Set up audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set up audio session")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create recognition request")
            return
        }

        let inputNode = audioEngine.inputNode
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { (buffer, time) in
            recognitionRequest.append(buffer)
        }

        // Start audio engine and recognition task
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine couldn't start")
            return
        }
        
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                // Update recognized text with best transcription
                recognizedText = result.bestTranscription.formattedString
            }
            if let error = error {
                print("Speech recognition failed: \(error)")
                stopRecording() // Stop recording if error occurs
            }
        }
    }

    // Stop recording user voice
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        // Use the recognized text as the user input
        userInput = recognizedText

        print("Recording stopped. Starting conversation...")

        // Start the continuous conversation with the recognized text
        handleContinuousConversation(initialMessage: recognizedText)
    }

    // Handle continuous conversation with Voiceflow
    func handleContinuousConversation(initialMessage: String) {
        var currentMessage = initialMessage

        func sendNextMessage() {
            sendToVoiceflow(message: currentMessage) { conversationEnded in
                if conversationEnded {
                    print("Conversation ended.")
                    return
                }

                // Use the last response from Voiceflow as the next message
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Small delay for better user experience
                    currentMessage = recognizedText
                    sendNextMessage() // Continue the conversation
                }
            }
        }

        sendNextMessage()
    }

    // Function to send recognized text to Voiceflow API and handle continuous conversation
    func sendToVoiceflow(message: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://general-runtime.voiceflow.com/state/user/67954f33464ea1636552ed4e") else {
            print("Invalid URL")
            return
        }

        // Prepare the request body with user input
        let requestBody: [String: Any] = [
            "type": "text",
            "payload": message  // User's input text
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer VF.DM.67954f766d87d3a9603037dc.aoKCnUUF2KWq5myV", forHTTPHeaderField: "Authorization") // Your API key
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        // Make the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending to Voiceflow: \(error)")
                completion(false)
                return
            }

            guard let data = data else {
                print("No data received from Voiceflow")
                completion(false)
                return
            }

            // Parse the response from Voiceflow
            do {
                if let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let voiceflowResponse = responseDict["payload"] as? String {
                    DispatchQueue.main.async {
                        // Update the UI with Voiceflow's response
                        recognizedText = voiceflowResponse
                    }

                    print("Voiceflow response: \(voiceflowResponse)")

                    // Check if Voiceflow signals the end of the conversation
                    if responseDict["end"] as? Bool == true {
                        completion(true) // End conversation
                    } else {
                        completion(false) // Continue conversation
                    }
                } else {
                    print("Failed to parse response")
                    completion(false)
                }
            } catch {
                print("Error parsing response: \(error)")
                completion(false)
            }
        }.resume()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

