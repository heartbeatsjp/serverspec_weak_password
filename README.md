# ServerspecWeakPassword

Utility to check specified user's password is so weak.

## What's weak password?
 
Basic password variation are...

- username in the host
- listed in the Wikipedia's List of the most common passwords
    - https://en.wikipedia.org/wiki/List_of_the_most_common_passwords

Based on above, below pattern's passwords are so weak!

- Just same as basic password : `PASSWORD`
- Repeat twice : `PASSWORDPASSWORD`
- Reverse : `DROWSSAP`
- Second is reverse : `PASSWORDDROWSSAP`

This gem generates weak password's hash.
(use hasy_type, salt in `/etc/shadow` )

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'serverspec_weak_password', :git => 'git@github.com:heartbeatsjp/serverspec_weak_password.git'
```

After we put gem to rubygems (planed)...

```ruby
gem 'serverspec_weak_password'
```

And then execute:

    $ bundle install

## Usage

```ruby
require 'serverspec_weak_password'
describe 'root password is not weak' do
  shadow = ServerspecWeakPassword::ServerspecWeakPassword.get_shadow('root')
  next if shadow.nil?

  it { expect(shadow[:hash]).not_to eq('') }
  next if shadow[:hash] == ''

  ServerspecWeakPassword::ServerspecWeakPassword.get_weak_hashes(shadow[:hash_type], shadow[:salt]).each do |hash|
    it { expect(shadow[:hash]).not_to eq(hash) }
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/heartbeatsjp/serverspec_weak_password.

# Release howto

1. `git checkout master && git pull`
2. `git checkout master`
3. rewrite `lib/serverspec_weak_password/version.rb`
4. append changes to `CHANGELOG.md`
5. `git commit`
6. `git push`
7. git tag
8. `git push --tags`
