# frozen_string_literal: true

require 'open-uri'
require 'aws-sdk-s3'

namespace :syg do

  desc 'Create a lost item record for each photo in S3'
  task create_lost_property_records: ['db:migrate'] do |_t|
    s3 = Aws::S3::Resource.new(access_key_id: Rails.application.credentials.dig(:aws, :access_key_id), 
                               secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key), 
                               region: APP_CONFIG[:s3_region])

    files = s3.bucket(APP_CONFIG[:s3_bucket]).objects(prefix: 'lost_property/')

    files.each do |item|
        next if item.key == 'lost_property/'
        puts item.key
        /^lost_property\/(.+)\.JPG/.match(item.key)
        name = Regexp.last_match(1).tr('_', ' ')
        file = s3.bucket(APP_CONFIG[:s3_bucket]).object(item.key).get.body

        item = LostItem.create(category: 'Update category',
                                description: 'Update description')
        item.photo.attach(io: file,
            filename: "#{name}.JPG", content_type: 'image/jpeg', identify: false)
        puts "Created lost item for #{name}"
    end

    # Deleting keys from the bucket as they are processed has problems, as the bucket index
    # is messed around. So instead, we save all the keys up to be deleted later
    puts "Deleting all items files..."
    s3.bucket(APP_CONFIG[:s3_bucket]).objects(prefix: 'lost_property/').batch_delete!
  end
end
