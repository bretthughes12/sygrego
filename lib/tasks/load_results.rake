# frozen_string_literal: true

require 'open-uri'
require 'aws-sdk-s3'

namespace :syg do

  # NOTE: This takes some time - about 30 seconds per results file    
  desc 'Load the results files for each group'
  task load_results: ['db:migrate'] do |_t|
    s3 = Aws::S3::Resource.new(access_key_id: Rails.application.credentials.dig(:aws, :access_key_id), 
                               secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key), 
                               region: APP_CONFIG[:s3_region])

    files = s3.bucket(APP_CONFIG[:s3_bucket]).objects(prefix: 'results_files/')

    files.each do |result|
        next if result.key == 'results_files/'
        /^results_files\/SYG_\d+_Results_(\w+)\.pdf/.match(result.key)
        if Regexp.last_match(1).nil?
            puts "No match to #{result.key}"
        else
            abbr = Regexp.last_match(1).tr('_', ' ')
            /^results_files\/(.+)\.pdf/.match(result.key)
            name = Regexp.last_match(1).tr('_', ' ')
            group = Group.find_by_abbr(abbr)
            file = s3.bucket(APP_CONFIG[:s3_bucket]).object(result.key).get.body

            if group.nil?
                puts "Could not locate group with abbr: #{abbr}"
            else
                if group.results_file.attached?
                    puts "Deleting existing file..."
                    group.results_file.purge 
                end
                puts "Attaching new file..."
                group.results_file.attach(io: file,
                    filename: "#{name}.pdf", content_type: 'application/pdf', identify: false)
            end
        end
    end

    # Deleting keys from the bucket as they are processed has problems, as the bucket index
    # is messed around. So instead, we save all the keys up to be deleted later
    puts "Deleting all results files..."
    s3.bucket(APP_CONFIG[:s3_bucket]).objects(prefix: 'results_files/').batch_delete!
  end
end
