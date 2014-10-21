# Farscape
[![Build Status](https://travis-ci.org/mdsol/farscape.svg)](https://travis-ci.org/mdsol/farscape)

Farscape is a hypermedia agent that simplifies consuming Hypermedia API responses. It shoots through wormholes with
[Crichton](https://github.com/mdsol/crichton) at the helm and takes you to unknown places in the universe!

Checkout the [Documentation][] for more info.

NOTE: THIS IS UNDER HEAVY DEV AND IS NOT READY TO BE USED YET


## API Entry
There are various flavors of configuration that Farscape supports for entering a Hypermedia API. These all assume
a response with a supported Hypermedia media-type and a root that lists available resources as links.

### A Hypermedia API
For a interacting with an API (or individual service that supports a list of resources at its root), you enter the
API and follow your nose using the `enter` method on the agent. This method returns a [Farscape::Representor]() 
instance with a simple state-machine interface of `attributes` (data) and `transitions` (link/form affordances) for 
interacting with the resource representations.

```ruby
agent = Farscape::Agent.new('http://example.com/my_api')

resources = agent.enter
resources.attributes # => { meta: 'data', or: 'other data' }
resources.transitions.keys # => ['http://example.com/rel/drds', 'http://example.com/rel/leviathans']
```

### A Hypermedia Discovery Service
For interacting with a discovery service, Farscape supports follow your nose entry to select a registered resource
or immediately loading a discoverable resource if known to be registered in the service *a priori*. 

```ruby
agent = Farscape::Agent.new('http://example.com/my_discovery_service')

resources = agent.enter
resources.attributes # => { meta: 'data', or: 'other data' }
resources.transitions.keys # => ['http://example.com/rel/drds', 'http://example.com/rel/leviathans', 'next', 'last']

drds = agent.enter('http://example.com/rel/drds')
drds.attributes # => { total_count: 25, items: [...] }
drds.transitions.keys # => ['self', 'search', 'create', 'next', 'last']

agent.enter('http://example.com/rel/unknown_resource') # => raises Farscape::Agent::UnknownEntryPoint
```

## API Interaction
Entering an API takes you into its application state-machine and, as such, the interface for interacting with that 
application state is brain dead simple with Farscape. You have data that you read and hypermedia affordances that tell 
you what you can do next and you can invoke those affordances to do things. That's it.

Farscape recognizes a number of media-types that support runtime knowledge of the underlying REST uniform-interface 
methods. For these full-featured media-types, the interaction with with resources is as simple as a browser where 
implementation of requests is completely abstracted from the user.

The following simple examples highlight interacting with resource state-machines using Farscape.

### Load a resource
```ruby
resources = agent.enter
drds_transition = resources.transitions['http://example.com/rel/drds']
drds = drds_transition.invoke
```

### Reload a resource
```ruby
self_transition = drds.transitions['self']
reloaded_drds = self_transition.invoke
```

### Apply query parameters
```ruby
search_transition = drds.transitions['search']
search_transition.parameters # => ['search_term']

filtered_drds = search_transition.invoke do |builder|
  builder.parameters = { search_term: '1812' }
end
```

### Transform resource state
```ruby
embedded_drd_items = drds.items

drd = embedded_drd_items.first
drd.attributes # => { name: '1812' }
drd.transitions # => ['self', 'edit', 'delete', 'deactivate', 'leviathan']

deactivate_transition = drd.transitions['deactivate']

deactivated_drd = deactivate_transition.invoke
deactivated_drd.attributes # => { name: '1812' }
deactivated_drd.transitions # => ['self', 'activate', 'leviathan']

deactivate_transition.invoke # => raise Farscape::Agent::Gone error
```

### Transform application state
```ruby
leviathan_transition = deactivated_drd.transitions['leviathan']

leviathan = leviathan_transition.invoke
leviathan.attributes # => { name: 'Elack' }
leviathan.transitions # => ['self', 'drds']
```

### Use attributes

```ruby
create_transition = drds.transitions['create']
create_transition.attributes # => ['name']

new_drd = create_transition.invoke do |builder|
  builder.attributes = { name: 'Pike' }
end

new_drd.attributes # => { name: 'Pike' }
new_drd.transitions # => ['self', 'edit', 'delete', 'deactivate', 'leviathan']
```

For more examples and information on using Faraday with media-types that require specifying uniform-interface methods 
and other protocol idioms when invoking transitions, see [Using Farscape]().

## Alternate Interface

For developers more used to ActiveRecord syntax, Farscape resources also expose all transitions and attributes as Ruby methods. Safe (i.e. read) transitions are exposed verbatim.

```ruby
drd.leviathan # => Equivalent to drd.transitions['leviathan'].invoke
```

Unsafe transitions have an exclamation point at the end.

```ruby
drd.deactivate # => Raises NoMethodError

drd.deactivate! # => Equivalent to drd = drd.transitions['deactivate'].invoke
```

Request parameters can be passed as a hash or as a block.

```ruby
# The following are all equivalent:

drd = drds.create!(name: 'Pike')
drd = drds.create! { |builder| builder.attributes = {name: 'Pike'} }
drd = drds.transitions['create'].invoke{ |d| d.attributes = {name: 'Pike'} }
```

Attributes are read-only.

```ruby
drd.name # => "Pike"

drd.name = 'Susan' # => Raises NoMethodError
```

If an attribute or transition's name conflicts with an existing method or reserved word, it will not be methodized and must be accessed through the hash interface.


## Contributing
See [CONTRIBUTING][] for details.

## Copyright
Copyright (c) 2013 Medidata Solutions Worldwide. See [LICENSE][] for details.

[Crichton]: https://github.com/mdsol/crichton
[CONTRIBUTING]: CONTRIBUTING.md
[Documentation]: http://rubydoc.info/github/mdsol/farscape/develop/file/README.md
[LICENSE]: LICENSE.md
