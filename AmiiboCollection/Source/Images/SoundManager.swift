//
//  SoundManager.swift
//
//  Created by Phil on 8/15/18.
//  Copyright © 2018 Brook Street Games. All rights reserved.
//
import AVFoundation

///
/// Provides interface for playing music and sound effects.
///
final class SoundManager {
    
    // MARK: - Singleton -
    
    static let shared = SoundManager()
    private init() {}
    
    // MARK: - Properties -
    
    /// Object used to play sounds.
    private var soundPlayer: AVAudioPlayer?
    
    ///
    /// Plays a .wav sound effect.
    ///
    /// - parameter soundName: The name of the sound effect.
    ///
    func playSound(_ soundName: String) {
        
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            
            soundPlayer = try AVAudioPlayer(contentsOf: soundURL, fileTypeHint: AVFileType.wav.rawValue)
            soundPlayer?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    ///
    /// Stops playing sound.
    ///
    func stopSound() {
        soundPlayer?.pause()
    }
}
