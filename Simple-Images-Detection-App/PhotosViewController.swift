//
//  PhotosViewController.swift
//  Simple-Images-Detection-App
//
//  Created by 佐伯小遥 on 2025/05/19.
//

import UIKit
import AVFoundation

class PhotosViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var generatedTextLabel: UILabel!
    
    private let promptText: String = "以下の動画には何が映っていますか？説明してください。"
    
    private var resultText: String = ""

    var takenImage: UIImage?
    var takenVideoURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = takenImage {
            imageView.isHidden = false
            imageView.image = image
            recognizeImage(image)
        } else if let videoURL = takenVideoURL {
            imageView.isHidden = true
            playVideo(videoURL)
            summarizeVideo()
        }
    }


    private func recognizeImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        Task {
            let result = await MachineLearningHelper.shared.generateTextfromImage(imageData: imageData)
            DispatchQueue.main.async {
                self.generatedTextLabel.text = result
            }
        }
    }

    
    func summarizeVideo() {
        guard let videoURL = takenVideoURL else { return }
        Task {
            do {
                let images = try await VideoSummarizeHelper.extractFrames(from: videoURL)
                for try await result in MachineLearningHelper().sendMessage(text: "These are video frames.", images: images, systemMessage: promptText) {
                    guard let choice = result.choices.first else { return }
                    let message = choice.delta.content ?? ""
                    Task.detached { @MainActor in
                        self.resultText += message
                        self.generatedTextLabel.text = self.resultText
                    }
                    if let finishReason = choice.finishReason {
                        print("Stream finished with reason:\(finishReason).")
                        break
                    }
                }
            } catch {
                print("Failed to summarize video with error: \(error)")
            }
        }
    }



    private func playVideo(_ url: URL) {
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width * 9 / 16)
        view.layer.addSublayer(playerLayer)
        player.play()
    }
}


class VideoSummarizeHelper {
    static func extractFrames(from videoURL: URL) async throws -> [Data] {
        return try await VideoUtils.extractFrames(from: videoURL, timeInterval: 5.0, maximumSize: CGSize(width: 768, height: 768)).map { $0.data! }
    }
}
