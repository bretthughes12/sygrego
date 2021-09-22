# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Create the singleton Setting record...
Setting.create if Setting.count = 0

# Create static page entries for the information and policy pages
Page.create(name: "About Us",
            permalink: "info",
            admin_use: true)
Page.create(name: "Terms and Conditions",
            permalink: "terms",
            admin_use: true)
Page.create(name: "Privacy Policy",
            permalink: "privacy",
            admin_use: true)
Page.create(name: "Participant Image Use Policy",
            permalink: "image",
            admin_use: true)