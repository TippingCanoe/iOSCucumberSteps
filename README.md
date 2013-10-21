iOSCucumberSteps
================

a set of common ios cucumber steps

for use with cocoapods

add this to your podfile
```
target 'MyProject-cal', :exclusive => false do
    pod 'iOSCucumberSteps', :head
end
```
and add this to calabash_steps.rb

```ruby
require File.expand_path('../../../Pods/iOSCucumberSteps/general_steps.rb', __FILE__)
```
