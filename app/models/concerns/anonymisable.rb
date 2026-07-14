module Anonymisable
  extend ActiveSupport::Concern

  def anonymise!
    if self.class.respond_to?(:anonymisable_fields)
      self.class.anonymisable_fields.each do |field, method|
        self.send("#{field}=", method.call(self))
      end
      self.save
    end
  end
end