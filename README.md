# WebexApi

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/webex_api`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'webex_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install webex_api

## Usage

    client = WebexApi::Client.new("webex_username","webex_password","site_id","site_name","partner_id","webex_email")

##### Create Meeting

    options = {
        duration: 10,
        emails: [] ,
        scheduled_date: Time.now + 5.minutes,
        meeting_password: "admin123"
         time_zone: Time.zone
    }
    meeting_key = client.create_meeting(meeting_name,options)

##### Meeting Info
    client.get_meeting(meeting_key)

##### Meeting Host Url
    client.get_meeting_host_url(meeting_key)

##### Meeting Join Url
    client.get_meeting_join_url(meeting_key)    

##### Delete meeting 
    client.delete_meeting(meeting_key)

##### Add Attendee to meeting
    options = {
      :name=>"",
      :address_type=>"PERSONAL",
      :role=>"ATTENDEE or PRESENTER or HOST"
    }

    client.add_attendee_to_meeting(meeting_key,"email,options)    

##### Remove Attendee from meeting
    client.delete_attendee_from_meeting(meeting_key,"amardaxini@gmail.com") 

##### List Attendee for meeting
    client.list_attendee_for_meeting(meeting_key)       

## TODO
  Add Event API


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/webex_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

