Pod::Spec.new do |s|
  s.name             = 'EvolvKit'
  s.version          = '1.2.5'
  s.summary          = 'Autonomous Optimization Tool'
  s.description      = <<-DESC
  'This SDK is designed to be integrated into projects to allow for autonomous UI optimizations'
  DESC
  s.homepage         = 'https://github.com/evolv-ai/EvolvKit'
  s.license          = { :type => 'APACHE', :file => 'LICENSE' }
  s.author           = { 'Evolv' => 'phyllis.wong@evolv.ai' }
  s.source           = { :git => 'https://github.com/evolv-ai/EvolvKit.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'
  s.ios.deployment_target = '9.0'
  s.source_files     = 'Source/**/*.swift'
  s.dependency 'Alamofire', '~> 4.8.0'
  s.dependency 'PromiseKit', '~> 6.0'
end
