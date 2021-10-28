FactoryBot.define do
  factory :group_signup do
    sequence(:name)       { |n| "Test group#{n}" }
    address               {"123 Main St"}
    suburb                {"Maintown"}
    postcode              {"3999"}
    phone_number          {"0395557777"}
    sequence(:email)      { |n| "group#{n}email@email.com" }
    sequence(:website)    { |n| "www.group#{n}.com" }      
    denomination          {"Baptist"}
    sequence(:church_rep_email)      { |n| "roy#{n}@orbison.com" }
    sequence(:church_rep_name)       { |n| "Roy Orbison #{n}" }
    church_rep_role       {"Pastor"}
    church_rep_address    {"123 Main St"}
    church_rep_suburb     {"Maintown"}
    church_rep_postcode   {"3999"}
    church_rep_phone_number  {"0395557777"}
    church_rep_wwcc_number   {"123456789"}
    sequence(:gc_email)      { |n| "chuck#{n}@berry.com" }
    sequence(:gc_name)       { |n| "Chuck Berry #{n}" }
    gc_address            {"123 Main St"}
    gc_suburb             {"Maintown"}
    gc_postcode           {"3999"}
    gc_phone_number       {"0395557777"}
    gc_wwcc_number        {"123456789"}
    gc_reference          {"Elvis Presley"}
    gc_reference_phone    {"0395557777"}
  end
end
