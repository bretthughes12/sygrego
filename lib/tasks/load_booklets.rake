# frozen_string_literal: true

require 'open-uri'
require 'aws-sdk-s3'

namespace :syg do

  # NOTE: This takes some time - about 30 seconds per booklet    
  desc 'Load the customised group handbook booklets for each group'
  task load_booklets: ['db:migrate'] do |_t|
    s3 = Aws::S3::Resource.new(access_key_id: Rails.application.credentials.dig(:aws, :access_key_id), 
                               secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key), 
                               region: APP_CONFIG[:s3_region])

    files = s3.bucket(APP_CONFIG[:s3_bucket]).objects(prefix: 'booklet_files/')

    files.each do |booklet|
        next if booklet.key == 'booklet_files/'
        /^booklet_files\/SYG-\d+-A4-Booklet-(.+)\.pdf/.match(booklet.key)
        if Regexp.last_match(1).nil?
            puts "No match to #{booklet.key}"
        else
            abbr = Regexp.last_match(1).tr('-', ' ')
            /^booklet_files\/(.+)\.pdf/.match(booklet.key)
            name = Regexp.last_match(1).tr('-', ' ')
            group = Group.find_by_abbr(abbr)
            file = s3.bucket(APP_CONFIG[:s3_bucket]).object(booklet.key).get.body

            if group.nil?
                puts "Could not locate group with abbr: #{abbr}"
            else
                if group.booklet_file.attached?
                    puts "Deleting existing file..."
                    group.booklet_file.purge 
                end
                puts "Attaching new file..."
                group.booklet_file.attach(io: file,
                    filename: "#{name}.pdf", content_type: 'application/pdf', identify: false)
            end
        end
    end

    # Deleting keys from the bucket as they are processed has problems, as the bucket index
    # is messed around. So instead, we save all the keys up to be deleted later
    puts "Deleting all booklet files..."
    s3.bucket(APP_CONFIG[:s3_bucket]).objects(prefix: 'booklet_files/').batch_delete!
  end
end
