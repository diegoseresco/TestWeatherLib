Pod::Spec.new do |spec|

  spec.name         = "TestWeatherLib"
  spec.version      = "1.6"
  spec.summary      = "A framework which contains functionalities about GoogleMaps"
  spec.description  = "A framework that has functionalities in KML, Markers, tracking and much more! using GoogleMaps"

  spec.homepage     = "https://github.com/diegoseresco/TestWeatherLib"
  spec.license      = "MIT"
  spec.author             = { "diego" => "92336377+diegosalcedov@users.noreply.github.com" }
  spec.platform     = :ios, "13.0"

  spec.source       = { :git => "https://github.com/diegoseresco/TestWeatherLib.git", :tag => spec.version.to_s }
  spec.source_files  = "TestWeatherLib/**/**"
  spec.swift_versions = "5.0"
  spec.dependency "Alamofire", "~> 4.7"
  #spec.dependency "GoogleMaps", "~> 5.1.0"
  #spec.frameworks = "GoogleMapsCore", "GoogleMapsBase", "GoogleMaps"
  #spec.static_framework = true
  #spec.dependency 'GoogleMaps'
  #spec.static_framework = true
  #spec.requires_arc = true
end