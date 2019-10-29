#
#  Be sure to run `pod spec lint BrainBlocksKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "BrainBlocksKit"
  s.version      = "2.0"
  s.summary      = "A Payment Framework for Nano."

  s.description  = "The BrainBlocksKit is a complete payment framework that can be used in any iOS app to accept Nano."

  s.homepage     = "https://github.com/brainblocks/brainblocks-ios-sdk"

  s.license      = { :type => 'BrainBlocks License, Version 1.0', :text => <<-LICENSE
      Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

      The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software, along with credit to the BrainBlocks company and platform.
      The software may be used free of charge in commercial applications, providing it is used in conjunction with the BrainBlocks payments platform and BrainBlocks back-end servers.
      The software shall not be copied, forked, or modified in any way to be used with payments platforms other than BrainBlocks.
      The software may be copied, forked, or modified to make improvements, bug fixes, patches, security fixes, etc. providing the software continues to use BrainBlocks as its sole payments platform, and no other, and changes of general utility are offered in good faith back into the main repository in reasonable time in the form of a pull request, which may be accepted or rejected by the BrainBlocks team.
      Any changes or pull requests made into the main repository shall be the sole property of BrainBlocks, including any and all copyrights and intellectual property rights, with credit to the original author.
      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    LICENSE
  }

  s.author       = "BrainBlocks"

  s.platform     = :ios, "12.0"

  s.source       = { :git => "https://github.com/brainblocks/brainblocks-ios-sdk.git", :tag => "v#{s.version}" }

  s.source_files  = "BrainBlocksKit", "BrainBlocksKit/**/*.{h,m,swift}"

  s.resource_bundles = {
    'BrainBlocksKit' => ['BrainBlocksKit/*.{storyboard,xib,png,svg}']
  }

  s.dependency 'Alamofire', '~> 5.0.0-rc.3'
  s.dependency 'QRCode'
  s.dependency 'SwiftyJSON', '~> 4.0'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5' }
  s.swift_version = '5'

end
