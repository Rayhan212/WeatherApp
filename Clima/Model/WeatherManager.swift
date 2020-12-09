//
//  WeatherManager.swift
//  Clima
//
//  Created by Rayhan Hidayat on 23/11/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weatherManager:WeatherManager, weather: WeatherModel)
    func didFAilWithError(error: Error)
    
}

struct WeatherManager {
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=f2a326bd173fa5c0317107286fa6515d&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString: urlString)
        
    }
    
//    Networking
    func performRequest(urlString: String) {
//        1.Crate URL
        if let url = URL(string: urlString){
//            2.Create URL session
            let session = URLSession(configuration: .default)
//            3. Give he session a task
            let task = session.dataTask(with: url){(data,urlResponse,error) in
            
                
                if error != nil{
                    self.delegate?.didFAilWithError(error: error!)
                    return
                }
                if let safeData = data{
                   if let weather = self.parseJSON(safeData){
                    self.delegate?.didUpdateWeather(weatherManager: self, weather: weather)
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
        let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(condition: id, name: name, temperature: temp)
            return weather
                        
            
        }catch{
            delegate?.didFAilWithError(error: error)
            return nil
        }
        
    }
   
}
