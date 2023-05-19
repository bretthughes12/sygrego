module Ticketable
  extend ActiveSupport::Concern

  included do
    before_update :ticket_update
  end

  private

  def ticket_update
    if ticket_fields_updated?
      self.dirty = true
    end
  end

  def ticket_fields_updated?
    if self.class.respond_to?(:ticket_fields)
      self.class.ticket_fields.each do |field|
        return true if self.send("#{field}_changed?")
      end
      return false
    else
      true
    end
  end
end