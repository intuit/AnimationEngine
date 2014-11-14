Pod::Spec.new do |s|
  s.name                  = "INTUAnimationEngine"
  s.version               = "1.2.0"
  s.homepage              = "https://github.com/intuit/AnimationEngine"
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { "Tyler Fox" => "tyler_fox@intuit.com" }
  s.source                = { :git => "https://github.com/intuit/AnimationEngine.git", :tag => "v1.2.0" }
  s.source_files          = 'Source'
  s.platform              = :ios
  s.ios.deployment_target = '5.0'
  s.requires_arc          = true
  s.summary               = "Easily build advanced custom animations on iOS."
  s.description           = <<-DESC
  INTUAnimationEngine makes it easy to build advanced custom animations on iOS.

  INTUAnimationEngine provides a friendly interface to drive custom animations using a CADisplayLink, inspired by the UIView block-based animation API. It enables interactive animations (normally driven by user input, such as a pan or pinch gesture) to run automatically over a given duration. It can also be used to get a callback every frame of an animation.

  INTUAnimationEngine includes an extensive library of easing functions that can be used to customize animation timing. A complete library of interpolation functions is also included to animate any type of value or property, including those that are not animatable by Core Animation.
  DESC
  
end
