# @title Crichton Configuration

## Configuration
Farscape supports a DSL that allows configuring agents and rack middleware in the request/response stack. You can 
generate a default configuration template in your application using:

```
$ bundle exec rake config:generate_all
```

This will create [dice_bag]() template `root/config/initializers/farscape.dice` that you can modify for 12-Factor 
Application deployment with different middlewares, etc.

```ruby
# farscape.dice

Farscape.config do
  # ...
end
```
Or, you can run:

```
$ bundle exec rake config:all
```

which will create an populated initializer `root/config/initializers/farscape.rb`:
 
 ```ruby
 # farscape.rb
 
 Farscape.config do
   # ...
 end
 ```
