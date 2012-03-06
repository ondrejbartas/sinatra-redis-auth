# -*- encoding : utf-8 -*-
module SessionDatabase

  def self.config_session
    if File.exists?('config/redis_config.yml')
      conf = YAML.load_file('config/redis_config.yml')[ENV['RACK_ENV'] || 'development'].symbolize_keys
      conf[:db] = conf[:session_db]
      conf
    else
      FileUtils.mkdir_p('config') unless File.exists?('config')
      FileUtils.cp(File.join(File.dirname(__FILE__),"../config/redis_config.yml.example"), 'config/redis_config.yml.example')
      raise ArgumentError, "Redis configuration file does not exists -> 'config/redis_config.yml', please provide it! I have created example file in config directory..."
    end
  end
    
  def self.url
    conf = self.config_session
    "redis://#{conf[:host]}:#{conf[:port]}/#{conf[:db]}"
  end

end