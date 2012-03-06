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