//
//  WeatherRepository.swift
//  WeatherForecastApp
//
//  Created by Edmer De Jesus Alarte on 2025/10/11.
//

import Foundation

protocol WeatherRepository {
    func getWeather(for city: String, completion: @escaping (WeatherData?) -> Void)
}

final class WeatherRepositoryImpl: WeatherRepository {
    private let api: WeatherAPIService
    private let db: RealmManager
    private let queue = OperationQueue()
    
    init(api: WeatherAPIService, db: RealmManager) {
        self.api = api
        self.db = db
        queue.maxConcurrentOperationCount = 2
    }
    
    func getWeather(for city: String, completion: @escaping (WeatherData?) -> Void) {
        let op = BlockOperation { [weak self] in
            guard let self = self else { return }
            let semaphore = DispatchSemaphore(value: 0)
            var data: WeatherData?
            
            self.api.fetchWeather(city: city) { result in
                switch result {
                case .success(let model):
                    self.db.save(model)
                    data = model
                case .failure:
                    if let cached = self.db.fetch(for: city) {
                        data = WeatherData(city: cached.city, temperature: cached.temperature, windSpeed: cached.windSpeed, time: cached.time)
                    }
                }
                semaphore.signal()
            }
            
            semaphore.wait()
            DispatchQueue.main.async {
                completion(data)
            }
        }
        queue.addOperation(op)
    }
}

