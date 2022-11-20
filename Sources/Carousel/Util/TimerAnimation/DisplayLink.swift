//
//  DisplayLink.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

import AppKit
import OSLog

final class DisplayLink {
    // MARK: - Properties

    private let timer: CVDisplayLink
    private let source: DispatchSourceUserDataAdd

    var callback: (() -> Void)?

    var isRunning: Bool { return CVDisplayLinkIsRunning(timer) }

    // MARK: - Initialization

    init?(onQueue queue: DispatchQueue = DispatchQueue.main) {

        source = DispatchSource.makeUserDataAddSource(queue: queue)

        var displayLink: CVDisplayLink? = nil

        var resultCode = CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)

        if let timer = displayLink {

            let displayLinkCallback: CVDisplayLinkOutputCallback = {
                (timer: CVDisplayLink,
                 currentTime: UnsafePointer<CVTimeStamp>,
                 outputTime: UnsafePointer<CVTimeStamp>,
                 _ : CVOptionFlags,
                 _ : UnsafeMutablePointer<CVOptionFlags>,
                 sourceUnsafeRaw : UnsafeMutableRawPointer?) -> CVReturn in

                if let sourceUnsafeRaw = sourceUnsafeRaw {
                    let sourceUnmanaged = Unmanaged<DispatchSourceUserDataAdd>.fromOpaque(sourceUnsafeRaw)
                    sourceUnmanaged.takeUnretainedValue().add(data: 1)
                }

                return kCVReturnSuccess
            }

            resultCode = CVDisplayLinkSetOutputCallback(
                timer,
                displayLinkCallback,
                Unmanaged.passUnretained(source).toOpaque()
            )

            guard resultCode == kCVReturnSuccess else {
                os_log(.error, log: OSLog.default, "[DisplayLink] Failed to create timer with active display")
                return nil
            }

            resultCode = CVDisplayLinkSetCurrentCGDisplay(timer, CGMainDisplayID())

            guard resultCode == kCVReturnSuccess else {
                os_log(.error, log: OSLog.default, "[DisplayLink] Failed to connect to display")
                return nil
            }

            self.timer = timer
        } else {
            os_log(.error, log: OSLog.default, "[DisplayLink] Failed to create timer with active display")
            return nil
        }

        source.setEventHandler(handler: { [weak self] in self?.callback?() })
    }

    deinit {
        if isRunning {
            cancel()
        }
        source.cancel()
    }

    // MARK: - API

    func start() {
        guard !isRunning else { return }

        CVDisplayLinkStart(timer)

        source.resume()
    }

    func cancel() {
        guard isRunning else { return }

        CVDisplayLinkStop(timer)
        source.cancel()
    }
}
