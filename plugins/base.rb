=begin
BasePlugin class.

Provides the following helpful features:
- _foo: prints "I am a helper function" to the screen. (

Usage:
Define a new plugin class with following code in your
plugins/<plugin_name>/plugin.rb.
```
class Thing < BasePlugin
  [...]
end
```
=end
class BasePlugin

  def _foo
    puts "I am a helper function"
  end

end
