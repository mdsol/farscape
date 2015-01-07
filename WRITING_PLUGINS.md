# Writing Plugins

Farscape Plugins can be used to add drop-in functionality to Farscape. 

# Registration

To register your plugin, run 

```ruby
Farscape.register_plugin(name: :cachinator, type: :cache, ...)
```

Feel free to put this code at the bottom of `cachinator.rb` so that it turns on automatically after the gem is loaded. Consumers who want control can include a line in their initializer reading `Farscape.disable(:cachinator)` or `Farscape.disable(:cache)`. If you'd rather have your plugin be off by default, you could instead wrap the register_plugin call in, say, a `Cachinator.activate` method for the consumer to call as desired. If your plugin is http-specific (say it adds Authentication headers), include `protocol: :http`.

# Adding Middleware

You can probably do what you need to do by writing [Faraday](https://github.com/lostisland/faraday)-style middleware. Middleware can inspect and alter outgoing requests and incoming responses, abort requests, and define hooks that run after a request/response cycle completes. All it needs to do is obey [a simple API](https://github.com/lostisland/faraday#writing-middleware).

To add your middleware to the stack, run

```ruby
Farscape.register_plugin(name: :cachinator, type: :cache, middleware: [Cachinator::Middleware], ...)
```

If you need to partially order your middleware, the elements of the middleware array can be hashes of the form:

```ruby
{ class: Cachinator::Middleware,
  before: RequestSigner,
  after: ['HubSubscriber', 'Ouroborous', :authorization]
}
```

In this example, Cachinator::Middleware will be inserted before the RequestSigner middleware if it is present, and after the latest of HubSubscriber, Ouroborous, or any middleware of type "authorization". Note that Middleware classes can and should be given as strings if your plugin is not providing them, so that Ruby won't throw a NameError if they are undefined. If the ordering constraints given are impossible to satisfy, Farscape will throw an error.

You can also add config to your middleware when passing it in hash form:

```ruby
{ class: Cachinator::Middleware,
  config: MyApp.config[:cache]
}
```

The config hash will be passed to your middleware as a second argument to `new`, as in Faraday. To pass multiple arguments, use `config: [arg1, arg2]`.

# Extending Agent

If you want to provide a more interactive API, or reference the deserialized response using the Representor interface, you can define a module that will be available to mix in to Farscape::Agent.

```ruby
module Peacekeeper
  def pacify!
    raise if representor.transitions.keys.include?(:attack)
  end
end
Farscape.register_plugin(name: :peacekeeper, agent_extension: Peacekeeper, ...)
agent.enter(url).using(:peacekeeper).pacify!
```

# Farscape Utilities

Any plugin can reference `Farscape.cache`, which exposes [the same API as Rails.cache](http://apidock.com/rails/ActiveSupport/Cache/Store), `Farscape.logger`, which exposes [the same API as the built-in Ruby logger](http://apidock.com/ruby/Logger). By default, Farscape.cache operates in-memory and Farscape.logger writes to STDOUT. Plugins can provide enhanced versions of these utilities by modifying the global state of the Farscape object:

```ruby
module Peacekeeper
  class DalliCache
    # code that implements the Cache api
  end
end
Farscape.cache = Peacekeeper::DalliCache.new(config)
```

Future updates will provide Farscape.jobs, a backgrounding utility along similar lines.

# Creating a Client

By default, Farscape uses the [Net::HTTP](http://ruby-doc.org/stdlib-2.1.5/libdoc/net/http/rdoc/Net/HTTP.html) library to make HTTP requests. You can replace this client with `Faraday.clients[:http] = MyClient` or define one for a new protocol with `Faraday.clients[:amqp] = Jessica::Rabbit`. When a Farscape agent follows a link with a given protocol, it will use the client for that protocol if one has been provided. Required interface tk.
