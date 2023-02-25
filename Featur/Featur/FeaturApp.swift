//
//  FeaturApp.swift
//  Featur
//
//  Created by iakalann on 24/02/2023.
//

import SwiftUI
import Firebase

@main
struct FeaturApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ProfileView()
        }
    }
}
