# Farscape
[![Build Status](https://travis-ci.org/mdsol/farscape.svg)](https://travis-ci.org/mdsol/farscape)

Farscape is a hypermedia agent that simplifies consuming Hypermedia API responses. It shoots through wormholes with
[Crichton](https://github.com/mdsol/crichton) at the helm and takes you to unknown places in the universe!

NOTE: THIS IS UNDER HEAVY DEV AND IS NOT READY TO BE USED YET


## Accessing Hypermedia APIs
For interacting with an API you enter the API URL and follow your nose using the `invoke` method on the agent.
This method returns a Farscape::Representor instance with a simple state-machine interface of `properties` (data)
and `transitions` (link/form affordances) for interacting with the resource representations.

```ruby
api_root = Farscape.invoke('http://example.com/my_api')
api_root.properties # => { meta: 'data', name: 'some name' }
```

You can keep invoking transitions to follow your nose on that API.

```ruby
api_root = Farscape.invoke('http://example.com/my_api')
api_root.properties # => { meta: 'data', name: 'some name' }
first_element = api_root.invoke('first')
first_element.invoke('delete')
```

If you check the transitions you want to invoke beforehand by using the .transitions method of the representor
or an inexistent transition gets invoked, you will get an Farscape::UnknownTransition error.

Test individual transitions:
```ruby
api_root = Farscape.invoke('http://example.com/my_api')
first_element = api_root.invoke('first')
if first_element.transitions['wronglink']
  first_element.invoke('wronglink')
else
...
```

Catch all unknown transition errors:
```ruby
  api_root = Farscape.invoke('http://example.com/my_api')
  api_root.properties # => { meta: 'data', name: 'some name' }
  first_element = api_root.invoke('first')
  first_element.invoke('wronglink')
rescue Farscape::UnknownTransition
....
```


## API Interaction
Entering an API takes you into it's application state-machine and, as such, the interface for interacting with that
application state is brain dead simple with Farscape. You have data that you read and hypermedia affordances that tell
you what you can do next and you can invoke those affordances to do things. That's it.

Farscape recognizes a number of media-types that support runtime knowledge of the underlying REST uniform-interface
methods. For these full-featured media-types, the interaction with with resources is as simple as a browser where
implementation of requests is completely abstracted from the user.
Farscape is based on [Representors](https://github.com/mdsol/crichton-representors/) and it supports the same types
Representors support now.

The following simple examples highlight interacting with resource state-machines using Farscape.

### Load resources
```ruby
resources = Farscape.invoke('http://example.com/rel/drds')
drds_transition = resources.transitions['all']
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

filtered_drds = search_transition.invoke({ search_term: '1812' })
```

### Transform resource state
```ruby
resources = Farscape.invoke('http://example.com/rel/drds')
embedded_drd_items  = resources.invoke('all')

drd = embedded_drd_items.first
drd.properties # => { name: '1812' }
drd.transitions # => ['self', 'edit', 'delete', 'deactivate', 'leviathan']

deactivate_transition = drd.transitions['deactivate']

deactivated_drd = deactivate_transition.invoke
deactivated_drd.properties # => { name: '1812' }
deactivated_drd.transitions # => ['self', 'activate', 'leviathan']
```

### Transform application state
```ruby
leviathan_transition = deactivated_drd.transitions['leviathan']

leviathan = leviathan_transition.invoke
leviathan.properties # => { name: 'Elack' }
leviathan.transitions # => ['self', 'drds']
```

### Use attributes

```ruby
create_transition = drds.transitions['create']
create_transition.attributes # => ['name']

new_drd = create_transition.invoke({ name: 'Pike' })

new_drd.properties # => { name: 'Pike' }
new_drd.transitions # => ['self', 'edit', 'delete', 'deactivate', 'leviathan']
```


## Contributing
See [CONTRIBUTING][] for details.

## License
See [LICENSE][] for details.


## Copyright
Copyright (c) 2013 Medidata Solutions Worldwide. See [LICENSE][] for details.

[Crichton]: https://github.com/mdsol/crichton
[CONTRIBUTING]: CONTRIBUTING.md
[Documentation]: http://rubydoc.info/github/mdsol/farscape/develop/file/README.md
[LICENSE]: LICENSE.md
