Sinatra Redis Auth
==================

Simple authetication for sinatra based applications. It saves all datas -> user data + session data to redis.

It is absolutely insane to use slow databases (MySQL, Postgre ...) for those datas. redis provides very fast possibility to acces thousands user datas per second.

Installation of requirments
--------------------------

Redis - [detailed instructions](http://redis.io/download):

``` ruby
wget http://redis.googlecode.com/files/redis-2.4.8.tar.gz
tar xzf redis-2.4.8.tar.gz
cd redis-2.4.8
make
```

or you can use brew
``` ruby
brew install redis
```

Example of usage
----------------

In `example/` you can find functional application with all needed parts.

Including to existing application
---------------------------------

``` ruby
#Gemfile
gem "sinatra-redis-auth"
```

``` ruby
#your_sinatra_app.rb
register Sinatra::SinatraRedisAuth
```

create two files in `config/` directory: `mail_config.rb`, `redis_config.yml`

``` ruby
#config/mail_config.rb
Mailer.delivery_method[:type] = :sendmail
Mailer.credentials[:from] = 'askme@weps.cz'
Mailer.credentials[:subject] = "Password reset"
Mailer.credentials[:body] = "Someone hopefully you, requested password rest"
```
_settings for emailing when user need's to reset password_

``` yaml
#config/redis_config.yml
test:
  host: "127.0.0.1"
  port: 6379
  db: 3
  session_db: 5
development:
  host: "127.0.0.1"
  port: 6379
  db: 0
  session_db: 1
stage:
  host: "127.0.0.1"
  port: 6379
  db: 0
  session_db: 1
production:
  host: "127.0.0.1"
  port: 6379
  db: 0
  session_db: 1
```
_settings for connecting application to redis_

*You need to create user model too (do not forget to require it in your app)*

``` ruby
# user.rb
# -*- encoding : utf-8 -*-
class User
  REDIS_MODEL_CONF = {
      :fields => {
      :email => :to_s,
      :password => :to_s,
      :salt => :to_s,
      :reset_token => :to_s,
    }, 
      :required => [:email,:password],
      :redis_key => [:email],
      :redis_aliases => {
      :reset_token => [:reset_token]
    }
  }
  include RedisModel
  initialize_redis_model_methods REDIS_MODEL_CONF
  include UserAuthModel
end
```

Options you can set
-------------------

You can set sinatra options for path to your edited sign in, sign out, password\_change, password\_reset

Or you can set where user will be redirected after sign in, up and out.

``` ruby
#your_sinatra_app.rb
set :sinatra_redis_auth_views, "views/"
set :default_url_after_sign_in, "/"
set :default_url_after_sign_up, "/"
set :default_url_after_sign_out, "/"
```


Contributing to redis-auth
-------------------------- 

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Copyright (c) 2012 Ondrej Bartas.