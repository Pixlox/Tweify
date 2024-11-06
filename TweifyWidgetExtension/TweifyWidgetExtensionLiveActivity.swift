//
//  TweifyWidgetExtensionLiveActivity.swift
//  TweifyWidgetExtension
//
//  Created by Omar Hafeezullah on 28/10/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TweifyWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TweifyWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TweifyWidgetExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TweifyWidgetExtensionAttributes {
    fileprivate static var preview: TweifyWidgetExtensionAttributes {
        TweifyWidgetExtensionAttributes(name: "World")
    }
}

extension TweifyWidgetExtensionAttributes.ContentState {
    fileprivate static var smiley: TweifyWidgetExtensionAttributes.ContentState {
        TweifyWidgetExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TweifyWidgetExtensionAttributes.ContentState {
         TweifyWidgetExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TweifyWidgetExtensionAttributes.preview) {
   TweifyWidgetExtensionLiveActivity()
} contentStates: {
    TweifyWidgetExtensionAttributes.ContentState.smiley
    TweifyWidgetExtensionAttributes.ContentState.starEyes
}
