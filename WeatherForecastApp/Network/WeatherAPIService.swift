//
//  WeatherAPIService.swift
//  WeatherForecastApp
//
//  Created by Edmer De Jesus Alarte on 2025/10/11.
//
import Foundation
import Alamofire

protocol WeatherAPIService {
    func fetchWeather(city: String, completion: @escaping (Result<WeatherData, Error>) -> Void)
}

final class WeatherAPIServiceImpl: WeatherAPIService {
    func fetchWeather(city: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        guard let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NSError(domain: "Invalid city", code: -1)))
            return
        }

        let url = "https://api.open-meteo.com/v1/forecast?latitude=35.6895&longitude=139.6917&current_weather=true"

        AF.request(url)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    // Decode off the main actor to satisfy Sendable
                    Task.detached {
                        do {
                            let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
                            let model = WeatherData(
                                city: city,
                                temperature: decoded.current_weather.temperature,
                                windSpeed: decoded.current_weather.windspeed,
                                time: decoded.current_weather.time
                            )
                            // Hop back to main actor to update UI
                            await MainActor.run {
                                completion(.success(model))
                            }
                        } catch {
                            await MainActor.run {
                                completion(.failure(error))
                            }
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
    }
}

// MARK: - Models for decoding

struct OpenMeteoResponse: Codable, Sendable {
    let current_weather: CurrentWeather
}

struct CurrentWeather: Codable, Sendable {
    let temperature: Double
    let windspeed: Double
    let time: String
}




