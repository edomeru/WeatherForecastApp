//
//  WeatherDataActor.swift
//  WeatherForecastApp
//
//  Created by Edmer De Jesus Alarte on 2025/10/11.
//
import Foundation

actor WeatherDataActor {
    private(set) var recentWeather: [WeatherData] = []
    
    func add(_ data: WeatherData) {
        recentWeather.append(data)
        if recentWeather.count > 5 {
            recentWeather.removeFirst()
        }
    }
    
    func getRecent() -> [WeatherData] {
        return recentWeather
    }
}


