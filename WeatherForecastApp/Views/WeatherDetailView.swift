//
//  WeatherDetailView.swift
//  WeatherForecastApp
//
//  Created by Edmer De Jesus Alarte on 2025/10/11.
//
import SwiftUI

struct WeatherDetailView: View {
    let data: WeatherData
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading) {
                    Text(data.city)
                        .font(.title2.bold())
                    Text("As of \(data.time)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            
            Text("\(data.temperature, specifier: "%.1f")°C")
                .font(.system(size: 60, weight: .medium))
                .foregroundStyle(.white)
            
            HStack {
                Label("\(data.windSpeed, specifier: "%.1f") m/s", systemImage: "wind")
                    .foregroundStyle(.white)
            }
            .font(.headline)
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
        .shadow(radius: 8)
    }
}


