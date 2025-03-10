class SignupSportPreference 
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :sport_id,
                :sport,
                :preference

  INTEGER_FIELDS = %w[sport_id preference].freeze

  validates :preference, 
    numericality: { only_integer: true },
    allow_blank: true

  def initialize(attributes = {})
    send_attributes(attributes)
    @sport = find_sport
  end
  
  def persisted?
    false
  end

  def send_attributes(attributes = {})
    attributes.each do |name, value|
      if INTEGER_FIELDS.include?(name)
        value = value.to_i
      else
        value = value.strip if value.respond_to?(:strip)
      end

      send("#{name}=", value)
    end
  end

  private

  def find_sport
    Sport.where(id: @sport_id).first
  end
end
