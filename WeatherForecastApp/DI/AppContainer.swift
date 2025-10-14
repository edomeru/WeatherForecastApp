//
//  Untitled.swift
//  WeatherForecastApp
//
//  Created by Edmer De Jesus Alarte on 2025/10/11.
//
import Swinject

struct AppContainer {
    static func setup(container: Container) {
        container.register(RealmManager.self) { _ in RealmManager() }.inObjectScope(.container)
        container.register(WeatherAPIService.self) { _ in WeatherAPIServiceImpl() }
        container.register(WeatherRepository.self) { r in
            WeatherRepositoryImpl(api: r.resolve(WeatherAPIService.self)!, db: r.resolve(RealmManager.self)!)
        }
        container.register(WeatherViewModel.self) { r in
            WeatherViewModel(repo: r.resolve(WeatherRepository.self)!)
        }
    }
}

