//
//  WeatherSearchView.swift
//  WeatherForecastApp
//
//  Created by Edmer De Jesus Alarte on 2025/10/11.
//
import SwiftUI

struct WeatherSearchView: View {
    @EnvironmentObject var vm: WeatherViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.6), .orange.opacity(0.3)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Weather Forecast")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                HStack {
                    TextField("Enter city name", text: $vm.city)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Button(action: { vm.search() }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Circle().fill(.blue))
                    }
                }
                
                if vm.isLoading {
                    ProgressView("Fetching weather...")
                        .tint(.white)
                } else if let data = vm.weather {
                    WeatherDetailView(data: data)
                }
                
                if !vm.recent.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Recent Searches")
                            .font(.headline)
                            .foregroundStyle(.white)
                        ForEach(vm.recent, id: \.city) { w in
                            Text("\(w.city): \(w.temperature, specifier: "%.1f")°C")
                                .foregroundStyle(.white.opacity(0.8))
                        }

                    }.padding()
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

