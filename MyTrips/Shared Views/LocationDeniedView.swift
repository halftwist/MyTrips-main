//
//  LocationDeniedView.swift
//  MyTrips
//
//  Created by John Kearon on 6/27/25.
//

import SwiftUI

struct LocationDeniedView: View {
    var body: some View {
        //        ContentUnavailableView(label: <#T##() -> View#>, description: <#T##() -> View#>, actions: <#T##() -> View#>)
        // To have all the options included hold the option key down then click when selecting the code from code completion
        //        Then do CTRL-M to get all the parameters displayed on a seperate line
//        ContentUnavailableView(
//            label: {
//                Text(
//                    "Location Services"
//                )
//            },
//            description: {
//                Text(
//                    "Please enable location services"
//                )
//            },
//            actions: {
//                Text(
//                    "Settings"
//                )
//            })
//        ContentUnavailableView("Tihs is a test", systemImage: "mappin.slash")
        ContentUnavailableView(
            label: {  // Don't know why code completion didn't insert opening and closing brackets
                Label("Location Services", image: "launchScreen")
            },
            description: {
                // use 3 quotes to allow multiple lines with embeded quotes
                Text("""
    1. Tab the button below and go to "Privacy and Security"
    2. Tap on "Location Services"
    3. Locate the "MyTrips" app and tap on it
    4. Change the setting to "While Using the App"
    """)
                .multilineTextAlignment(.leading)
            },
            actions: {
                Button(action: {
                    UIApplication.shared.open(
                        URL(string: UIApplication.openSettingsURLString)!,
                        options: [:],
                        completionHandler: nil
                    )
                }) {
                    Text("Open Settings")
                }
                .buttonStyle(.borderedProminent)
            }
        )
    }
}

#Preview {
    LocationDeniedView()
}
