import UIKit
import SwiftUI

/// Utility to detect device type and provide device-specific sizing
enum DeviceInfo {
    /// Detect if the current device is an iPad
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// Detect if the current device is an iPhone
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /// Size multiplier based on device type
    /// iPad: 1.5x, iPhone: 1.0x
    static var sizeMultiplier: CGFloat {
        isIPad ? 2 : 1.0
    }
    
    /// Spacing multiplier based on device type
    /// iPad: 1.5x, iPhone: 1.0x
    static var spacingMultiplier: CGFloat {
        isIPad ? 1.5 : 1.0
    }
    
    /// Padding multiplier for UI elements
    /// iPad: 1.5x, iPhone: 1.0x
    static var paddingMultiplier: CGFloat {
        isIPad ? 2 : 1.0
    }
    
    /// Font size multiplier
    /// iPad: 1.2x, iPhone: 1.0x
    static var fontMultiplier: CGFloat {
        isIPad ? 1.4 : 1.0
    }
}
