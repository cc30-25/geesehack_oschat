//import SwiftUI
//import Speech
//import AVFoundation
//
//struct HomeView: View {
//    @State private var userInput: String = ""
//    @State private var isRecording: Bool = false
//    @State private var recognizedText: String = ""
//    @State private var conversationState: String = ""  // Store the conversation state to track conversation flow
//
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
//    private let audioEngine = AVAudioEngine()
//    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    @State private var recognitionTask: SFSpeechRecognitionTask?
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                Text("What do you want to do?")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .multilineTextAlignment(.center)
//                    .padding()
//                
//                // Displaying the recognized speech or the user input
//                Text("Recognized Text: \(recognizedText)")
//                    .padding()
//                    .foregroundColor(.gray)
//                
//                // TextField for typed input (fallback if speech recognition fails or isn't used)
//                TextField("Enter your request...", text: $userInput)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//                
//                // Microphone button for voice input
//                Button(action: {
//                    if isRecording {
//                        stopRecording()
//                    } else {
//                        startRecording()
//                    }
//                    
//                    isRecording.toggle()
//                }) {
//                    Image(systemName: isRecording ? "mic.slash.fill" : "mic.fill")
//                        .resizable()
//                        .frame(width: 50, height: 50)
//                        .foregroundColor(isRecording ? .red : .blue)
//                }
//                .padding()
//
//                // Next button for navigation
//                NavigationLink(destination: DetailsView(userInput: userInput)) {
//                    Text("Next")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//                .disabled(userInput.isEmpty) // Disable button if input is empty
//            }
//            .padding()
//            .onAppear {
//                requestSpeechRecognitionPermission()
//            }
//        }
//    }
//    
//    // Request authorization for speech recognition
//    func requestSpeechRecognitionPermission() {
//        SFSpeechRecognizer.requestAuthorization { authStatus in
//            DispatchQueue.main.async {
//                if authStatus != .authorized {
//                    print("Speech recognition not authorized")
//                }
//            }
//        }
//    }
//    
//    // Start recording user voice
//    func startRecording() {
//        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
//            print("Speech recognizer not available")
//            return
//        }
//
//        // Set up audio session
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//        } catch {
//            print("Failed to set up audio session")
//            return
//        }
//        
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = recognitionRequest else {
//            print("Unable to create recognition request")
//            return
//        }
//
//        let inputNode = audioEngine.inputNode
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { (buffer, time) in
//            recognitionRequest.append(buffer)
//        }
//
//        // Start audio engine and recognition task
//        audioEngine.prepare()
//        do {
//            try audioEngine.start()
//        } catch {
//            print("Audio engine couldn't start")
//            return
//        }
//        
//        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
//            if let result = result {
//                recognizedText = result.bestTranscription.formattedString
//            }
//            if let error = error {
//                print("Speech recognition failed: \(error)")
//                stopRecording()
//            }
//        }
//    }
//    
//    // Stop recording user voice
//    func stopRecording() {
//        audioEngine.stop()
//        recognitionRequest?.endAudio()
//        recognitionTask?.cancel()
//
//        userInput = recognizedText
//        sendToVoiceflow(message: recognizedText)
//    }
//    
//    // Send user input to Voiceflow API for dynamic conversation flow
//    func sendToVoiceflow(message: String) {
//        guard let url = URL(string: "https://general-runtime.voiceflow.com/state/user/67954f33464ea1636552ed4e") else {
//            print("Invalid URL")
//            return
//        }
//
//        // Prepare the request body with user input and conversation state
//        let requestBody: [String: Any] = [
//            "user_input": message,
//            "session_id": "unique_session_id",  // Your session ID to maintain conversation context
//            "conversation_state": conversationState  // Optional: Send the conversation state if needed
//        ]
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer VF.DM.67954f766d87d3a9603037dc.aoKCnUUF2KWq5myV", forHTTPHeaderField: "Authorization")
//        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
//
//        // Make the network request
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error sending to Voiceflow: \(error)")
//                return
//            }
//
//            guard let data = data else {
//                print("No data received from Voiceflow")
//                return
//            }
//
//            do {
//                if let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let message = responseDict["message"] as? String,
//                   let newConversationState = responseDict["conversation_state"] as? String {
//                    handleVoiceflowResponse(response: message)
//                    conversationState = newConversationState  // Update conversation state for next request
//                } else {
//                    print("Failed to parse response")
//                }
//            } catch {
//                print("Error parsing response: \(error)")
//            }
//        }.resume()
//    }
//    
//    // Handle Voiceflow's response (i.e., the next question in the conversation)
//    func handleVoiceflowResponse(response: String) {
//        print("Voiceflow response: \(response)")
//        // Display or process the response accordingly
//    }
//}
//
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
//




import SwiftUI
import Speech
import AVFoundation
import Foundation


struct HomeView: View {
    @State private var userInput: String = ""
    @State private var isRecording: Bool = false
    @State private var recognizedText: String = ""
    @State private var voiceflowResponse: String = "Waiting for response..."  // New state for API response
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Main Text Display
                Text("What do you want to do?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Display the API response
                Text("Response: \(voiceflowResponse)")
                    .padding()
                    .foregroundColor(.gray)

                // Input TextField
                TextField("Enter your request...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Microphone Button for Speech Input
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

                // Send Button to Call Voiceflow API
                Button(action: {
                    sendToVoiceflowAPI(message: userInput) { response in
                        DispatchQueue.main.async {
                            voiceflowResponse = response ?? "No response received"
                        }
                    }
                }) {
                    Text("Send to Voiceflow")
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
                    // Handle error if permission is not granted
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
        
        print("Recording stopped")
        
        // Send recognized text to Voiceflow API
        sendToVoiceflow(message: recognizedText)
    }
    
    // Function to send recognized text to Voiceflow API
    func sendToVoiceflow(message: String) {
        guard let url = URL(string: "https://general-runtime.voiceflow.com/state/user/67954f33464ea1636552ed4e") else {
            print("Invalid URL")
            return
        }

        // Prepare the request body with user input
        let requestBody: [String: Any] = [
            "user_input": message,  // User's input text
            "session_id": "unique_session_id",  // You can generate or store session IDs
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
                return
            }

            guard let data = data else {
                print("No data received from Voiceflow")
                return
            }

            // Parse the response from Voiceflow
            do {
                if let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let message = responseDict["message"] as? String {
                    handleVoiceflowResponse(response: message)  // Handle the response
                } else {
                    print("Failed to parse response")
                }
            } catch {
                print("Error parsing response: \(error)")
            }
        }.resume()
    }
    
    // Handle response from Voiceflow API
    func handleVoiceflowResponse(response: String) {
        // You can update UI or take further action based on Voiceflow's response
        print("Voiceflow response: \(response)")
        // Example: Update a view or alert user with the response
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

