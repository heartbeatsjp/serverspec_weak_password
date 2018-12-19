require "serverspec_weak_password/version"
require 'specinfra'
require 'unix_crypt'

module ServerspecWeakPassword
  class ServerspecWeakPassword
    
    # https://en.wikipedia.org/wiki/List_of_the_most_common_passwords
    WEAK_PASSWORDS = [
      '!@#$%^&*',
      '000000',
      '111111',
      '121212',
      '123123',
      '1234',
      '12345',
      '123456',
      '1234567',
      '12345678',
      '123456789',
      '1234567890',
      '1qaz2wsx',
      '654321',
      '666666',
      '696969',
      'Football',
      'aa123456',
      'abc123',
      'access',
      'admin',
      'adobe123',
      'ashley',
      'azerty',
      'bailey',
      'baseball',
      'batman',
      'charlie',
      'donald',
      'dragon',
      'flower',
      'football',
      'freedom',
      'hello',
      'hottie',
      'iloveyou',
      'jesus',
      'letmein',
      'login',
      'loveme',
      'master',
      'michael',
      'monkey',
      'mustang',
      'ninja',
      'passw0rd',
      'password',
      'password1',
      'photoshop',
      'princess',
      'qazwsx',
      'qwerty',
      'qwerty123',
      'qwertyuiop',
      'shadow',
      'solo',
      'starwars',
      'sunshine',
      'superman',
      'trustno1',
      'welcome',
      'whatever',
      'zaq1zaq1',
    ]    
        
    def self.parse_shadow(line)
      elem = line.split(':')
      username = elem[0]
      if elem[1] == '!!' || elem[1] == '*' || elem[1] == '' || elem[1].nil?
        return { 'username': username, 'hash_type': '', 'salt': '', 'hash': '' }
      end
      parsed = parse_password_field(elem[1])
    
      # return
      parsed[:username] = username
      parsed
    end
    
    def self.parse_password_field(password_field)
      return { 'hash_type': '', 'salt': '', 'hash': '' } if password_field == '' || password_field.nil?
    
      hash_type = password_field.split('$')[1]
      salt = password_field.split('$')[2]
      hash = password_field.split('$')[3]
    
      # return
      { 'hash_type': hash_type, 'salt': salt, 'hash': hash }
    end
    
    def self.build_shadow(hash_type, salt, password)
      return UnixCrypt::MD5.build(password, salt) if hash_type == '1'
      return UnixCrypt::SHA256.build(password, salt) if hash_type == '5'
      return UnixCrypt::SHA512.build(password, salt) if hash_type == '6'
    end

    def self.get_shadow(username)
      shadow_lines = Specinfra.backend.run_command('cat /etc/shadow').stdout.to_s
    
      shadow_lines.split.each do |line|
        shadow = parse_shadow(line)
        return shadow if shadow[:username] == username
      end
      return nil
    end

    def self.get_weak_hashes(hash_type, salt)
      weak_hashes = []
      usernames = []
      shadow_lines = Specinfra.backend.run_command('cat /etc/shadow').stdout.to_s
    
      shadow_lines.split.each do |line|
        shadow = parse_shadow(line)
        usernames.push(shadow[:username])
      end
      usernames.each do |password|
          weak_hashes.concat(weak_hash_variation(hash_type, salt, password))
      end

      WEAK_PASSWORDS.each do |password|
          weak_hashes.concat(weak_hash_variation(hash_type, salt, password))
      end

      return weak_hashes
    end

    def self.weak_hash_variation(hash_type, salt, password)
      weak_hashes = []

      # once
      weak_hashes.push(parse_password_field(build_shadow(hash_type, salt, password))[:hash])

      # twice
      p2 = password + password
      weak_hashes.push(parse_password_field(build_shadow(hash_type, salt, p2))[:hash])

      # reverse
      p_rev = password.reverse
      weak_hashes.push(parse_password_field(build_shadow(hash_type, salt, p_rev))[:hash])

      # second's reverse
      p_second_reverse = password + password.reverse
      weak_hashes.push(parse_password_field(build_shadow(hash_type, salt, p_second_reverse))[:hash])

      return weak_hashes
    end
  end
end
