Pod::Spec.new do |s|
  s.name             = 'EvolvKit'
  s.version          = '0.1.4'
  s.summary          = 'Autonomous Optimizations Tool'
  s.description      = <<-DESC
  'This SDK is designed to be integrated into projects to allow for autonomous UI optimozations'
  DESC
  s.homepage         = 'https://github.com/PhyllisWong/EvolvKit'
  s.license          = { :type => 'APACHE', :file => 'LICENSE' }
  s.author           = { 'PhyllisWong' => 'phyllis.wong@evolv.ai' }
  s.source           = { :git => 'https://github.com/PhyllisWong/EvolvKit.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'
  s.ios.deployment_target = '9.0'
  s.source_files     = 'Source/**/*.swift'
  s.dependency 'Alamofire'
  s.dependency 'SwiftyJSON', '~> 4.0'
  s.dependency 'PromiseKit', '~> 6.8'
end
