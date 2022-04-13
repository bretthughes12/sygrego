FactoryBot.define do
  factory :participant_signup do
    sequence(:first_name) { |n| "Jack#{n}" }
    sequence(:surname)    { |n| "Smith#{n}" }
    group
    coming                { true }
    spectator             { false }
    onsite                { true }
    age                   { 30 }
    gender                { "M" }
    coming_friday         { true }
    coming_saturday       { true }
    coming_sunday         { true }
    coming_monday         { true }
    address               {"123 Main St"}
    suburb                {"Maintown"}
    postcode              {"3999"}
    phone_number          {"0395557777"}
    sequence(:email)      { |n| "group#{n}email@email.com" }
    sequence(:login_email){ |n| "jack#{n}@smith.com" }
    sequence(:login_name) { |n| "Jack Smith #{n}" }
  end
end
