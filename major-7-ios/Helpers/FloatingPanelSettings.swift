//
//  File.swift
//  major-7-ios
//
//  Created by jason on 27/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import FloatingPanel

class MyFloatingPanelLayout: FloatingPanelLayout {
    var initialPosition: FloatingPanelPosition {
        return .tip
    }
    var supportedPositions: Set<FloatingPanelPosition> {
        return [.tip, .half]
    }
    
    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .half: return UIScreen.main.bounds.height / 3 * 2
        case .tip:  return 40.0
        default:    return nil
        }
    }
    
    func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        switch position {
        case .half: return 0.3
        case .tip:  return 0
        default:    return 0
        }
    }
}

class MyFloatingPanelBehavior: FloatingPanelBehavior {
    var velocityThreshold: CGFloat {
        return 15.0
    }
    
    func interactionAnimator(_ fpc: FloatingPanelController, to targetPosition: FloatingPanelPosition, with velocity: CGVector) -> UIViewPropertyAnimator {
        let timing = timingCurve(to: targetPosition, with: velocity)
        return UIViewPropertyAnimator(duration: 0.5, timingParameters: timing)
    }
    
    private func timingCurve(to: FloatingPanelPosition, with velocity: CGVector) -> UITimingCurveProvider {
        let damping = self.damping(with: velocity)
        return UISpringTimingParameters(dampingRatio: damping,
                                        frequencyResponse: 0.4,
                                        initialVelocity: velocity)
    }
    
    private func damping(with velocity: CGVector) -> CGFloat {
        switch velocity.dy {
        case ...(-velocityThreshold):
            return 0.7
        case velocityThreshold... :
            return 0.7
        default:
            return 1.0
        }
    }
}
