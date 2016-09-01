//
//  ViewController.swift
//  SCRecorderTest
//
//  Created by Alex Paterson on 1/09/2016.
//  Copyright © 2016 Alexander Paterson. All rights reserved.
//

import UIKit
import SCRecorder

class ViewController: UIViewController {
    
    let session = SCRecordSession()
    let recorder = SCRecorder()
    let player = SCPlayer()
    
    @IBOutlet weak var previewView: UIView!
    
    @IBOutlet weak var playbackView: UIView!
    

    @IBOutlet weak var timeLabel: UILabel!
    
    
    @IBAction func recordButtonPress(sender: AnyObject) {
        recorder.record()
    }

    @IBAction func pauseButtonPress(sender: AnyObject) {
        recorder.pause()
    }

    @IBAction func backspaceButtonPress(sender: AnyObject) {
        if recorder.isRecording {
            recorder.pause()
            return
        }
        
        session.removeLastSegment()
        updateTimeText(session)
    }
    

    @IBAction func playButtonPress(sender: AnyObject) {
        player.play()
    }
    
    @IBAction func saveButtonPress(sender: AnyObject) {
        session.mergeSegmentsUsingPreset(AVAssetExportPresetHighestQuality) { (url, error) in
            if (error == nil) {
                url?.saveToCameraRollWithCompletion({ (path, error) in
                    debugPrint(path, error)
                })
            } else {
                debugPrint(error)
            }
        }
    }


    override func viewDidLayoutSubviews() {
        recorder.previewView = previewView
        
        player.setItemByAsset(session.assetRepresentingSegments())
        let playerLayer = AVPlayerLayer(player: player)
        let bounds = playbackView.bounds
        playerLayer.frame = bounds
        playbackView.layer.addSublayer(playerLayer)
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!recorder.startRunning()) {
            debugPrint("Recorder error: ", recorder.error)
        }
        
        recorder.session = session
        recorder.device = AVCaptureDevicePosition.Front
        recorder.videoConfiguration.size = CGSizeMake(800,800)
        recorder.delegate = self
    }

}

extension ViewController: SCRecorderDelegate {
    
    func recorder(recorder: SCRecorder, didAppendVideoSampleBufferInSession session: SCRecordSession) {
        updateTimeText(session)
    }
    
    func updateTimeText(session: SCRecordSession) {
        self.timeLabel.text = String(session.duration.seconds)
    }
}

