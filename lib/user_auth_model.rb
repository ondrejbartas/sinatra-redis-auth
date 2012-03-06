# -*- encoding : utf-8 -*-

module UserAuthModel

  def self.included(base) 
    base.send :extend, ClassMethods         
    base.send :include, InstanceMethods  
  end
  
  module ClassMethods
    
    def authenticate(email, password)
      user = self.get(:email => email)
      if user && user.encrypt(password) == user.password     
        user
      else
        nil
      end
    end
    
  end
  
  module InstanceMethods
  
    def initialize(args = {})
      args.symbolize_keys!
      args[:salt] = random_string(10) if !args[:salt] && args[:password_new]
      args[:password] = encrypt(args[:password_new], args[:salt]) if args[:password_new]
      super(args)
    end
  
    def forgot_password
      self.reset_token = random_string(30)
      save
    end

    def change_password password_new
      pp self
      pp self.args[:salt]
      self.args[:password] = encrypt(password_new, self.salt)
    end

    def encrypt(password, salt = nil)
      if salt
        Digest::SHA1.hexdigest(password+salt)
      else
        Digest::SHA1.hexdigest(password+self.salt)
      end
    end

    def random_string(len)
      #generate a random password consisting of strings and digits
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      newpass = ""
      1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
      return newpass
    end

  end
  
end