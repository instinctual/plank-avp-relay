// SPDX-License-Identifier: GPL-3.0-or-later
import SwiftUI
import RelaySetupKit

@main
struct AVPRelayApp: App {
    var body: some Scene {
        WindowGroup {
            AVPRelayView()

        }
        .defaultSize(width: 820, height: 760)
    }
}
