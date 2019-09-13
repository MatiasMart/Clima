
import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&units=metric&&appid=d5ed2838d39cbd9df8a736989feb5f9d"
    
    var delegate: WeatherManagerDelegate?
    
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRecuest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitud: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitud)"
        performRecuest(with: urlString)
    }
    
    func performRecuest(with urlString: String) {
        //1. Create a URL
        
        if let fixedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            if let url = URL(string: fixedURLString) {
                
                //2. Create a URLSession
                
                let session = URLSession(configuration: .default)
                
                //3. Give the session a Task
                
                let task = session.dataTask(with: url) { data, response, error in
                    if error != nil {
                        self.delegate?.didFailWithError(error!)
                        return
                    }
                    
                    if let safeData = data {
                        if let weather = self.parseJSON(safeData) {
                            self.delegate?.didUpdateWeather(self, weather: weather)
                        }
                    }
                }
                
                //4. Start the task
                
                task.resume()
                
            } else {
                print("Malfermed URL")
            }
        }
        
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let cityName = decodedData.name
            
            let weather = WeatherModel(conditionID: id, cityName: cityName, temperature: temp)
            return weather
            
        } catch {
            self.delegate?.didFailWithError(error)
            return nil
        }
    }
    
    
}
