# frozen_string_literal: true

require 'open-uri'
require 'aws-sdk-s3'

namespace :syg do
  desc 'Update the draws for sport sections'
  task update_section_draws: ['db:migrate'] do |_t|
    s3 = Aws::S3::Resource.new(access_key_id: Rails.application.credentials.dig(:aws, :access_key_id), 
                               secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key), 
                               region: APP_CONFIG[:s3_region])

    files = s3.bucket(APP_CONFIG[:s3_bucket]).objects(prefix: 'draw_files/')

    files.each do |draw|
        next if draw.key == 'draw_files/'
        /^draw_files\/(.+)\.pdf/.match(draw.key)
        name = Regexp.last_match(1).tr('_', ' ')
        section = Section.find_by_name(name)
        file = s3.bucket(APP_CONFIG[:s3_bucket]).object(draw.key).get.body

        if section.nil?
            puts "Could not locate section with name: #{name}"
        else
            if section.draw_file.attached?
                puts "Deleting existing file..."
                section.draw_file.purge 
            end
            puts "Attaching new file..."
            section.draw_file.attach(io: file,
                filename: "#{name}.pdf", content_type: 'application/pdf', identify: false)
        end
    end

    # Deleting keys from the bucket as they are processed has problems, as the bucket index
    # is messed around. So instead, we save all the keys up to be deleted later
    puts "Deleting all draw files..."
    s3.bucket(APP_CONFIG[:s3_bucket]).objects(prefix: 'draw_files/').batch_delete!
  end
end
