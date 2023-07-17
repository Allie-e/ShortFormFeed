//
//  VideoPlayerView.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/15.
//

import UIKit
import AVKit

class VideoPlayerView: UIView {

    // 재생될때 레이어 잡아주는 객체
    var playerLayer: AVPlayerLayer?
    // 반복재생과 관련된 객체
    var playerLooper: AVPlayerLooper?
    // 먼저들어온 영상 나중에 재생
    var queuePlayer: AVQueuePlayer?
    var urlStr: String

    init(frame: CGRect, urlStr: String) {
        self.urlStr = urlStr
        super.init(frame: frame)

        let videoURL = URL(string: urlStr)!
        let playItem = AVPlayerItem(url: videoURL)

        self.queuePlayer = AVQueuePlayer(playerItem: playItem)
        playerLayer = AVPlayerLayer()

        playerLayer?.player = queuePlayer
        playerLayer?.videoGravity = .resizeAspectFill

        self.layer.addSublayer(playerLayer!)

        playerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: playItem)
        queuePlayer?.play()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 메모리 관리를 위함
    func cleanup() {
        queuePlayer?.pause()
        queuePlayer?.removeAllItems()
        queuePlayer = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}
