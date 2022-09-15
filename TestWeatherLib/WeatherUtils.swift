//
//  WeatherUtils.swift
//  TestWeatherLib
//
//  Created by diegitsen on 14/09/22.
//

import Foundation
import Alamofire
import UIKit

public struct WeatherUtils {
    
    public init() {}
    
    public func getTemperature() {
        print("the temperature is 19 grades")
    }
    
    public func getPrecipitation() {
        print("the precipitation is 19 grades")
    }
    
    public func printWeather() {
        MeteorologyApi().getWeatherPredictionsKey(municipalityId: "33007")
    }
    
}

class MeteorologyApi {
    
    struct endpoints {
        static let meteorologyPrediction = "api/prediccion/especifica/municipio/diaria/%@"
        static let weatherPrediction = "sh/%@"
    }
    
    public func getWeatherPredictionsKey(municipalityId: String) {
        
        let headers: HTTPHeaders = [
            "api_key": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJkaWVnaXRzZW5AZ21haWwuY29tIiwianRpIjoiMmFiZGQ0NGUtYjgyMi00MDY1LWE2NDItYzY3NmEwMWVmOGE4IiwiaXNzIjoiQUVNRVQiLCJpYXQiOjE2NjA5ODQ5OTAsInVzZXJJZCI6IjJhYmRkNDRlLWI4MjItNDA2NS1hNjQyLWM2NzZhMDFlZjhhOCIsInJvbGUiOiIifQ.fMHq_0qUNMC8MrNJz0IGbTU-8o0ZP-90iDdUBpQkNPM",
            "Content-Type": "application/json"
        ]
        let url = String(format: "https://opendata.aemet.es/opendata/\(endpoints.meteorologyPrediction)", municipalityId)
        
        let request = NetworkManager.unauthorizedSharedManager.request(url,
                                                                       method: .get,
                                                                       parameters: nil,
                                                                       encoding: URLEncoding.default,
                                                                       headers: headers)
        
        request.responseJSON { response in
            switch response.result {
            case .success(let predictionData):
                print("hey!!!!! uwuwuw \(predictionData)")
            case .failure(let error):
                print("Error in getWeatherPredictionsKey: \(error.localizedDescription)")
            }
        }
        
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
//    class func getWeatherPredictions(key: String, completion: @escaping (MunicipalityPrediction) -> ()) {
//
//        let headers: HTTPHeaders = [
//            "Content-Type": "application/json;charset=ISO-8859-15"
//        ]
//        let url = String(format: "\(Constants.BASE_URL)\(endpoints.weatherPrediction)", key)
//
//        let request = NetworkManager.unauthorizedSharedManager.request(url,
//                                                                       method: .get,
//                                                                       parameters: nil,
//                                                                       encoding: URLEncoding.default,
//                                                                       headers: headers)
//
//        request.responseString { response in
//            switch response.result {
//            case .success(let weatherPrediction):
//                let jsonData = weatherPrediction.data(using: .utf8)!
//                do {
//                    let decoder = JSONDecoder()
//                    let municipalityPredictions = try decoder.decode([MunicipalityPrediction].self, from: jsonData)
//                    DispatchQueue.main.async {
//                        if let weatherPrediction = municipalityPredictions.first {
//                            completion(weatherPrediction)
//                        }
//                    }
//                } catch {
//                    print (error)
//                }
//
//            case .failure(let error):
//                print("hey! error \(error.localizedDescription)")
//            }
//        }
//
//
//    }
    
}


struct NetworkManager {
    
    open class MyServerTrustPolicyManager: ServerTrustPolicyManager {
        open override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
            return ServerTrustPolicy.disableEvaluation
        }
    }
    
    enum Errors: Int {
        case wrongAppVersion = -3
        case unexpectedResponse = -2
        case unknown = -1
        case timeout = 0
        case unauthorized = 401
    }
    
    struct ApiError {
        let code: Int
        let message: String?
        let requestEndpoint: String
        let args: [String: Any]?
    }
    
    static let authorizedSharedManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
//        configuration.timeoutIntervalForRequest = Constants.Network.TIMEOUT
//        configuration.timeoutIntervalForResource = Constants.Network.TIMEOUT
        
        
        let retval = SessionManager(configuration: configuration, delegate: SessionDelegate(), serverTrustPolicyManager: MyServerTrustPolicyManager(policies: [:]))
        retval.adapter = JWTAccessTokenAdapter()
        retval.retrier = MyRetrier()
        
        return retval
    }()
    
    static let unauthorizedSharedManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
//        configuration.timeoutIntervalForRequest = Constants.Network.TIMEOUT
//        configuration.timeoutIntervalForResource = Constants.Network.TIMEOUT
        
        let retval = SessionManager(configuration: configuration, delegate: SessionDelegate(), serverTrustPolicyManager: MyServerTrustPolicyManager(policies: [:]))
        retval.adapter = MyAdapter()
        retval.retrier = MyRetrier()
        
        return retval
    }()
    
    
    static func handleError(error: Error,
                            response: HTTPURLResponse?,
                            endpoint: String) -> ApiError {
        if error._code == NSURLErrorTimedOut {
            return ApiError(code: Errors.timeout.rawValue,
                            message: error.localizedDescription,
                            requestEndpoint: endpoint,
                            args: nil)
        }
        
        if let response = response {
            if response.statusCode == 401 {
                return ApiError(code: Errors.unauthorized.rawValue,
                                message: error.localizedDescription,
                                requestEndpoint: endpoint,
                                args: nil)
            }
            
            return ApiError(code: response.statusCode,
                            message: error.localizedDescription,
                            requestEndpoint: endpoint,
                            args: nil)
        }
        
        return ApiError(code: Errors.unknown.rawValue,
                        message: error.localizedDescription,
                        requestEndpoint: endpoint,
                        args: nil)
    }
    
    static func getBodyError(data: Data?) -> [String: Any]? {
        if let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let dictionary = json as? [String: Any] {
            return dictionary
        }
        
        return nil
    }
}

// MARK: JWT Access Token Adapter
final class JWTAccessTokenAdapter: RequestAdapter {
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        let accessToken = "customToken"
        urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return urlRequest
    }
}

final class MyAdapter: RequestAdapter {
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return urlRequest
    }
}

final class MyRetrier: RequestRetrier {
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        
        if let response = request.task?.response as? HTTPURLResponse, (response.statusCode == 401 || response.statusCode == 403) {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .tokenExpired, object: nil)
            }
            
        }

        completion(false, 0.0)
    }
}

extension Notification.Name {
    static let tokenExpired = Notification.Name("tokenExpired")
}
