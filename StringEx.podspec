Pod::Spec.new do |spec|

  spec.name         = "StringEx"
  spec.version      = "1.0.0"
  spec.summary      = "StringEx makes it easy to create NSAttributedString and manipulate String."

  spec.homepage     = "https://github.com/andruvs/StringEx"
  spec.license      = { :type => "MIT", :file => "LICENSE.md" }
  spec.author             = { "andruvs" => "andruvs@gmail.com" }

  spec.ios.deployment_target = "10.0"
  spec.swift_version = "5.2"

  spec.source       = { :git => "https://github.com/andruvs/StringEx.git", :tag => "#{spec.version}" }

  spec.source_files  = "Sources/**/*.{h,m,swift}"

end
