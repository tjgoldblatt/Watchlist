//
//  PinchToZoom.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 7/10/23.
//

import Foundation
import SwiftUI

extension View {
    func addPinchZoom() -> some View {
        return PinchZoomContext {
            self
        }
    }
}

// Helper Struct
struct PinchZoomContext<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    // Offset and Scale Data
    @State var offset: CGPoint = .zero
    @State var scale: CGFloat = 0

    @State var scalePosition: CGPoint = .zero

    var body: some View {
        content
            // applying offset before sclaing ...
                .offset(x: offset.x, y: offset.y)
                // Using UIKit Gestures to recognize both Pan and Pinch gestures
                .overlay {
                    GeometryReader { proxy in
                        let size = proxy.size

                        ZoomGesture(size: size, scale: $scale, offset: $offset, scalePosition: $scalePosition)
                    }
                }
                // Scaling Content..
                .scaleEffect(1 + scale, anchor: .init(x: scalePosition.x, y: scalePosition.y))
    }
}

struct ZoomGesture: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    var size: CGSize
    @Binding var scale: CGFloat
    @Binding var offset: CGPoint

    @Binding var scalePosition: CGPoint

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.backgroundColor = .clear

        // adding Gestures
        let pinchGesture = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handlePinch(sender:))
        )
        view.addGestureRecognizer(pinchGesture)

        // add pan gesture
        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handlePan(sender:))
        )

        panGesture.delegate = context.coordinator

        view.addGestureRecognizer(panGesture)

        return view
    }

    func updateUIView(_: UIViewType, context _: Context) { }

    // Creating Handlers for Gestures
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: ZoomGesture

        init(parent: ZoomGesture) {
            self.parent = parent
        }

        // making pan to recognize simulateously ...
        func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
            return true
        }

        @objc
        func handlePan(sender: UIPanGestureRecognizer) {
            // setting maxtouches
            sender.maximumNumberOfTouches = 2

            // min scale is 1...
            if sender.state == .began || sender.state == .changed && parent.scale > 0 {
                if let view = sender.view {
                    // getting translation
                    let translation = sender.translation(in: view)
                    parent.offset = translation
                }
            } else {
                // Setting state back to normal
                withAnimation {
                    parent.offset = .zero
                    parent.scalePosition = .zero
                }
            }
        }

        @objc
        func handlePinch(sender: UIPinchGestureRecognizer) {
            // calculating scale..
            if sender.state == .began || sender.state == .changed {
                // setting scale

                // removing added 1
                parent.scale = (sender.scale - 1)

                // getting position where the user pinched and applying scale at that position
                let scalePoint = CGPoint(
                    x: sender.location(in: sender.view).x / sender.view!.frame.size.width,
                    y: sender.location(in: sender.view).y / sender.view!.frame.size.height
                )

                // so the result will be ((0..1), (0..1))

                // updating scale point for only once
                parent.scalePosition = (parent.scalePosition == .zero ? scalePoint : parent.scalePosition)
            } else {
                // setting scale to 0
                withAnimation(.easeInOut(duration: 0.35)) {
                    parent.scale = 0
                    parent.scalePosition = .zero
                }
            }
        }
    }
}
