//
//  CachedWeather.swift
//  WeatherForecastApp
//
//  Created by Edmer De Jesus Alarte on 2025/10/11.
//
import RealmSwift

class CachedWeather: Object {
    @Persisted(primaryKey: true) var city: String
    @Persisted var temperature: Double
    @Persisted var windSpeed: Double
    @Persisted var time: String
}


