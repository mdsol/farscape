# Writing Plugins

Farscape Plugins can be used to add drop-in functionality to Farscape. 

# Registration

To register your plugin, run 

```ruby
Farscape.register_plugin(name: :cachinator, type: :cache, ...)
```

Feel free to put this code at the bottom of `cachinator.rb` so that it turns on automatically after the gem is loaded. Consumers who want control can include a line in their initializer reading `Farscape.disable('cachinator')` or `Farscape.disable(:cache)`. If you'd rather have your plugin be off by default, you could instead wrap the register_plugin call in, say, a `Cachinator.activate` method for the consumer to call as desired. If your plugin is http-specific (say it adds Authentication headers), include `protocol: :http`.

# Adding Middleware

You can probably do what you need to do by writing [Faraday](https://github.com/lostisland/faraday)-style middleware. Middleware can inspect and alter outgoing requests and incoming responses, abort requests, and define hooks that run after a request/response cycle completes. All it needs to do is obey [a simple API](https://github.com/lostisland/faraday#writing-middleware).

To add your middleware to the stack, run

```ruby
Farscape.register_plugin(name: :cachinator, type: :cache, middleware: [Cachinator::Middleware], ...)
```

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

Any plugin can reference `Farscape.cache`, which exposes [the same API as Rails.cache](http://apidock.com/rails/ActiveSupport/Cache/Store), `Farscape.logger`, which exposes [the same API as the built-in Ruby logger](http://apidock.com/ruby/Logger), and `Farscape.jobs`, which enables asynchronous processing (API tk). By default, Farscape.cache operates in-memory, Farscape.logger writes to STDOUT, and Farscape.jobs will actually block and run synchronously. Plugins can provide enhanced versions of these utilities by modifying the global state of the Farscape object:

```ruby
module Peacekeeper
  class DalliCache
    # code that implements the Cache api
  end
end
Farscape.cache = Peacekeeper::DalliCache.new(config)
```

# Creating a Client

Farscape can have one client for each protocol. Currently the only protocol type we have clients for is HTTP. The default client is [Net::HTTP](http://ruby-doc.org/stdlib-2.1.5/libdoc/net/http/rdoc/Net/HTTP.html). You can replace this client with `Faraday.clients[:http] = MyClient` or define one for a new protocol with `Faraday.clients[:amqp] = Jessica::Rabbit`. When a Farscape agent follows a link with a given protocol, it will use the client for that protocol if one has been provided. Required interface tk.
