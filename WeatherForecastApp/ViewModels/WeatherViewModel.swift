//
//  WeatherViewModel.swift
//  WeatherForecastApp
//
//  Created by Edmer De Jesus Alarte on 2025/10/11.
//
import Foundation
import SwiftUI
import Combine

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var city = ""
    @Published var weather: WeatherData?
    @Published var isLoading = false
    @Published var recent: [WeatherData] = []
    
    private let repo: WeatherRepository
    private let actor = WeatherDataActor()
    
    init(repo: WeatherRepository) {
        self.repo = repo
    }
    
    func search() {
        guard !city.isEmpty else { return }
        isLoading = true
        repo.getWeather(for: city) { [weak self] data in
            guard let self = self else { return }
            self.isLoading = false
            if let data = data {
                self.weather = data
                Task {
                    await self.actor.add(data)
                    self.recent = await self.actor.getRecent()
                }
            }
        }
    }
}
