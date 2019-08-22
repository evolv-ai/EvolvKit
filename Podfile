source 'https://cdn.cocoapods.org/'
platform :ios, '9.0'

project 'EvolvKit'
use_frameworks!

abstract_target 'EvolvKit' do
  pod 'Alamofire', '~> 4.8.0'
  pod 'PromiseKit', '~> 6.0'
  
  target 'EvolvKit iOS' do
    supports_swift_versions '>= 5.0'
  end
  
  target 'EvolvKit iOS Tests' do
    inherit! :search_paths
  end
  
  target 'Example' do
    project 'Example/Example'
    workspace 'Example/Example'
    
    pod 'EvolvKit', :path => './'
  end
  
  target 'ExampleObjC' do
    project 'ExampleObjC/ExampleObjC'
    workspace 'ExampleObjC/ExampleObjC'
    
    pod 'EvolvKit', :path => './'
  end
end
