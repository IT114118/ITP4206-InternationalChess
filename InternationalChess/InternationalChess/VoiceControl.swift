//
//  VoiceControl.swift
//  InternationalChess
//
//  Created by Battlefield Duck on 6/1/2021.
//

import Speech

class VoiceControl {
    let audioEngine = AVAudioEngine()
    var speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var timer: Timer?
    
    func start() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat){ buffer, _ in
            self.recognitionRequest!.append(buffer)
        }
            
        audioEngine.prepare()
            
        do {
            try audioEngine.start()
        } catch {
            
        }
    }
    
    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionTask = nil
    }
    
    func setLocale(identifier: String) {
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: identifier))
    }
    
    static func tryGetInt(voiceCommand: String) -> Int? {
        if let cell = Int(voiceCommand) {
            return cell
        }
        
        let voiceCommand = voiceCommand.replacingOccurrences(of: "。", with: "")
        
        switch voiceCommand.lowercased() {
        case "one", "juan", "一", "日":
            return 1
        case "two", "to", "二", "姨":
            return 2
        case "three", "free", "v", "fee", "三":
            return 3
        case "four", "for", "fall", "是", "四":
            return 4
        case "five", "五", "唔", "呜":
            return 5
        case "six", "sex", "六":
            return 6
        case "seven", "七":
            return 7
        case "eight", "egg", "爸", "八":
            return 8
        case "nine", "lie", "night", "九", "夠":
            return 9
        default:
            return nil
        }
    }
}
