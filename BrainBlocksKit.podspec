#
#  Be sure to run `pod spec lint BrainBlocksKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "BrainBlocksKit"
  s.version      = "0.0.5"
  s.summary      = "A Payment Framework for Raiblocks."

  s.description  = "The BrainBlocksKit is a complete payment framework that can be used in any iOS app to accept Raiblocks."

  s.homepage     = "https://github.com/brainblocks/brainblocks-ios-sdk"

  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }

  s.author       = "BrainBlocks"

  s.platform     = :ios, "11.0"

  s.source       = { :git => "https://github.com/brainblocks/brainblocks-ios-sdk.git", :tag => "v#{s.version}" }

  s.source_files  = "BrainBlocksKit", "BrainBlocksKit/**/*.{h,m,swift}"

  s.resource_bundles = {
    'BrainBlocksKit' => ['BrainBlocksKit/*.{storyboard,xib,png}']
  }

  s.dependency 'Alamofire', '~> 4.5'
  s.dependency 'QRCode'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }

end
