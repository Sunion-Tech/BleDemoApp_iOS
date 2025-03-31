//
//  TimerManager.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2025/3/31.
//

import UIKit

/// 計時器管理器 - 低耦合、可重複使用
final class TimerManager {
    private var timer: Timer?

    /// 啟動計時器
    func start(interval: TimeInterval, repeats: Bool = true, handler: @escaping () -> Void) {
        stop() // 確保不重複啟動

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { _ in
            handler()
        }
    }

    /// 停止計時器
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    /// 是否正在運作中
    var isRunning: Bool {
        return timer != nil
    }
}
