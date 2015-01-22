Pod::Spec.new do |s|
  s.name         = "DMMSecretary"
  s.version      = "0.0.5"
  s.summary      = "When you just need someone to get handle notifications for you"

  s.description  = <<-DESC
                    Sometimes you just want something to hold onto or catch
                    some `NSNotification`s for you that you couldn't get because
                    you were not on screen or were unable to get them for some reason.

                    Well now you can. 
                   DESC

  s.homepage     = "https://github.com/dmiedema/DMMSecretary"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Daniel Miedema" => "danielmiedema@me.com" }
  s.social_media_url   = "http://twitter.com/no_good_ones"

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/dmiedema/DMMSecretary.git", :tag => "0.0.5" }

  s.source_files  = "DMMSecretary/*.{h,m}", "DMMSecretary/Private/*.{h,m}"
  s.public_header_files = "DMMSecretary/*.h"

  s.requires_arc = true

end
