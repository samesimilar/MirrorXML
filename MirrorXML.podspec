Pod::Spec.new do |s|
  s.name             = 'MirrorXML'
  s.version          = '4.0.0'
  s.summary          = 'A block-based, event-driven, API for parsing xml (and basic html).'
  s.description      = <<-DESC
  MirrorXML is a wrapper for libxml2's SAX (pull) xml and html parsers. It's also a wrapper for libxml2's streamable XPath pattern matching functionality.
  
  But those two things don't quite describe how these features work together in MirrorXML to make event-driven xml parsing easier.
  
  Let's put it another way: MirrorXML is a block-based, event-driven, API for parsing xml (and basic html).
  
  MirrorXML doesn't attempt to magically turn XML into Swift model objects, rather, it puts you in control while helping you create more easily maintainable, explicit, and well-strucutred code.
  
  And it also comes with a neat little customizeable *html to NSAttributedString* API.
                       DESC

  s.homepage         = 'https://github.com/samesimilar/MirrorXML'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mike Spears' => 'samesimilar@gmail.com' }
  s.source           = { :git => 'https://github.com/samesimilar/MirrorXML', :tag => s.version.to_s }

  s.osx.deployment_target = '10.11'
  s.ios.deployment_target = '9.0'

  s.source_files = 'MirrorXML/Classes/common/**/*'
  s.ios.source_files = 'MirrorXML/Classes/MXHTML-iOS/**/*'
  s.osx.source_files = 'MirrorXML/Classes/MXHTML-macOS/**/*'

  s.library = "xml2"
  s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  s.ios.framework = 'UIKit'
  s.osx.framework = 'Cocoa'
end
