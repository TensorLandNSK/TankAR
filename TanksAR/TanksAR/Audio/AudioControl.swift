//
//  audioControl.swift
//  TanksAR
//
//  Created by Vitaly Antipov on 20/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation
import AVFoundation

class AudioControl {
    private var bombSoundEffect: AVAudioPlayer
    private let path: String
    private let url: URL
    
    
    init(forResource: String) {
        path = Bundle.main.path(forResource: forResource, ofType: "mp3")!
        url = URL(fileURLWithPath: path)
        bombSoundEffect = try! AVAudioPlayer(contentsOf: url)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(.playback, mode: .default)
    }
    
    public func onPlay(volume: Float){

        bombSoundEffect.setVolume(volume, fadeDuration: 0)
        bombSoundEffect.play()
    }
}
