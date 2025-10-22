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

        // Get coordinates: use responseData and decode off-main-actor
        let geoURL = "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=1"

        AF.request(geoURL)
            .validate()
            .responseData { geoResponse in
                switch geoResponse.result {
                case .success(let geoDataRaw):
                    // Decode geocoding result off the main actor to satisfy Sendable requirements
                    Task.detached {
                        do {
                            let geoData = try JSONDecoder().decode(GeocodingResponse.self, from: geoDataRaw)
                            guard let location = geoData.results?.first else {
                                await MainActor.run {
                                    completion(.failure(NSError(domain: "City not found", code: -2)))
                                }
                                return
                            }

                            // Use coordinates to fetch weather
                            let weatherURL = "https://api.open-meteo.com/v1/forecast?latitude=\(location.latitude)&longitude=\(location.longitude)&current_weather=true&timezone=auto"

                            AF.request(weatherURL)
                                .validate()
                                .responseData { weatherResponse in
                                    switch weatherResponse.result {
                                    case .success(let weatherDataRaw):
                                        // Decode weather response off the main actor too
                                        Task.detached {
                                            do {
                                                let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: weatherDataRaw)
                                                // Format time
                                                let formattedTime = Self.formatDate(decoded.current_weather.time)
                                                let model = WeatherData(
                                                    city: location.name,
                                                    temperature: decoded.current_weather.temperature,
                                                    windSpeed: decoded.current_weather.windspeed,
                                                    time: formattedTime
                                                )
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
                                        // network error -> deliver on main actor
                                        DispatchQueue.main.async {
                                            completion(.failure(error))
                                        }
                                    }
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
    
    // MARK: - Date Formatting Helper
    private static func formatDate(_ isoString: String) -> String {
        // Try ISO8601 first
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]

        if let date = isoFormatter.date(from: isoString) {
            return date.formattedDateString()
        }

        // Fallback: try common formats manually
        let formats = [
            "yyyy-MM-dd'T'HH:mm",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssZ"
        ]

        let df = DateFormatter()
        for format in formats {
            df.dateFormat = format
            df.locale = Locale(identifier: "en_US_POSIX")
            if let date = df.date(from: isoString) {
                return date.formattedDateString()
            }
        }

        // If all fail, return raw
        return isoString
    }


}

// MARK: - Models

// Make these Sendable since we decode them off the main actor.
struct GeocodingResponse: Codable, Sendable {
    let results: [GeoResult]?
}

struct GeoResult: Codable, Sendable {
    let name: String
    let latitude: Double
    let longitude: Double
}

struct OpenMeteoResponse: Codable, Sendable {
    let current_weather: CurrentWeather
}

struct CurrentWeather: Codable, Sendable {
    let temperature: Double
    let windspeed: Double
    let time: String
}

// MARK: - Date Formatting Helper

private extension Date {
    func formattedDateString() -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: self)
    }
}







