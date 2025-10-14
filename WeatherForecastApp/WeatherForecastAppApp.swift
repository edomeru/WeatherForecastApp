//
//  WeatherForecastAppApp.swift
//  WeatherForecastApp
//
//  Created by Edmer De Jesus Alarte on 2025/10/11.
//

import SwiftUI
import Swinject

@main
struct WeatherForecastApp: App {
    private let container: Container = {
        let c = Container()
        AppContainer.setup(container: c)
        return c
    }()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WeatherSearchView()
                    .environmentObject(container.resolve(WeatherViewModel.self)!)
            }
        }
    }
}

