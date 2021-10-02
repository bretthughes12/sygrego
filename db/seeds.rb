# Create user roles
['admin', 'gc', 'church_rep', 'participant'].each do |role|
    r = Role.find_or_create_by({name: role})
    r.group_related = true if role == 'gc' || role == 'church_rep'
    r.participant_related = true if role == 'participant'
    r.save
end

admin_role = Role.find_by_name('admin')

# Create the superuser
User.create(email: "registrations@stateyouthgames.com",
            password: Rails.application.credentials.su_password,
            password_confirmation: Rails.application.credentials.su_password)

User.all.each do |u|
    u.roles << admin_role if u.roles.empty?
end
            
# Create the singleton Setting record...
Setting.create if Setting.count == 0

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

# Create the Admin group
Group.create(abbr: "ADM",
             name: "Administration team",
             short_name: "Admin",
             coming: true,
             admin_use: true,
             new_group: false,
             trading_name: "Administration team",
             address: "Lardner Park office",
             suburb: "Lardner",
             postcode: 3821,
             email: "info@stateyouthgames.com",
             phone_number: "0444 111 222",
             website: "https://stateyouthgames.com/vic",
             denomination: "Churches of Christ",
             status: "Approved",
             updated_by: 1
            )

# Create the Default group
Group.create(abbr: "DFLT",
             name: "I can't find my group",
             short_name: "No group",
             coming: true,
             admin_use: true,
             new_group: false,
             trading_name: "Choose this and we will help you",
             address: "Lardner Park office",
             suburb: "Lardner",
             postcode: 3821,
             email: "info@stateyouthgames.com",
             phone_number: "0444 111 222",
             website: "https://stateyouthgames.com/vic",
             denomination: "None",
             status: "Approved",
             updated_by: 1
            )

# Create the group for Day Visitors
Group.create(abbr: "DAY",
             name: "Day visitors",
             short_name: "Day visitors",
             coming: true,
             admin_use: true,
             new_group: false,
             trading_name: "Day visitors",
             address: "Lardner Park office",
             suburb: "Lardner",
             postcode: 3821,
             email: "info@stateyouthgames.com",
             phone_number: "0444 111 222",
             website: "https://stateyouthgames.com/vic",
             denomination: "None",
             status: "Approved",
             updated_by: 1
            )