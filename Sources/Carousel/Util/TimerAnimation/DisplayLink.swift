//
//  DisplayLink.swift
//  Carousel
//
//  Created by Serhiy Butz on 2022-11-19.
//

protocol DisplayLinkProtocol {
    var callback: (() -> Void)? { get set }
    func start()
    func cancel()
}

#if os(macOS)
import AppKit
import OSLog

final class DisplayLink: DisplayLinkProtocol {
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

#elseif os(iOS)
import UIKit

final class DisplayLink: DisplayLinkProtocol {
    // MARK: - Properties

    private var displayLink: CADisplayLink?
    var callback: (() -> Void)?

    // MARK: - Initialization

    deinit {
        if displayLink != nil {
            cancel()
        }
    }

    // MARK: - API

    func start() {
        guard displayLink == nil else { return }
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(handleDisplayLink)
        )
        displayLink!.add(to: .main, forMode: .common)
    }

    func cancel() {
        guard displayLink != nil else { return }

        displayLink!.invalidate()
        displayLink = nil
    }

    // MARK: - Lifecycle

    @objc func handleDisplayLink() {
        callback?()
    }
}
#endif
