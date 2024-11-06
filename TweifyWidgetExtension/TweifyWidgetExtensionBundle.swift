//
//  TweifyWidgetExtensionBundle.swift
//  TweifyWidgetExtension
//
//  Created by Omar Hafeezullah on 28/10/2024.
//

import WidgetKit
import SwiftUI

@main
struct TweifyWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        TweifyWidgetExtension()
        TweifyWidgetExtensionControl()
        TweifyWidgetExtensionLiveActivity()
    }
}
