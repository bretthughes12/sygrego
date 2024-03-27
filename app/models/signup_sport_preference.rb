class SignupSportPreference 
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :grade_id,
                :grade,
                :preference

  INTEGER_FIELDS = %w[grade_id preference].freeze

  validates :preference, 
    numericality: { only_integer: true },
    allow_blank: true

  def initialize(attributes = {})
    send_attributes(attributes)
    @grade = find_grade
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

  def find_grade
    Grade.where(id: @grade_id).first
  end
end
