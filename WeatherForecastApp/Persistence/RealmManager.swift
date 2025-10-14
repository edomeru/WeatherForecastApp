//
//  RealmManager.swift
//  WeatherForecastApp
//
//  Created by Edmer De Jesus Alarte on 2025/10/11.
//
import RealmSwift

final class RealmManager {
    private let realm = try! Realm()
    
    func save(_ weather: WeatherData) {
        let item = CachedWeather()
        item.city = weather.city
        item.temperature = weather.temperature
        item.windSpeed = weather.windSpeed
        item.time = weather.time
        try? realm.write {
            realm.add(item, update: .modified)
        }
    }
    
    func fetch(for city: String) -> CachedWeather? {
        realm.object(ofType: CachedWeather.self, forPrimaryKey: city)
    }
}


