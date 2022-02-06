# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(40)       default(""), not null
#  group_role             :string(100)
#  address                :string(200)
#  suburb                 :string(40)
#  postcode               :integer          default("0")
#  phone_number           :string(30)
#  gc_reference           :string(40)
#  gc_reference_phone     :string(30)
#  years_as_gc            :integer          default("0")
#  primary_gc             :boolean          default("false")
#  status                 :string(12)       default("Not Verified")
#  wwcc_number            :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_name                  (name)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  include Searchable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_and_belongs_to_many :roles
  has_and_belongs_to_many :groups

  scope :primary, -> { where(primary_gc: true) }
  scope :stale, -> { where(status: "Stale") }
  scope :not_stale, -> { where("status != 'Stale'") }

  encrypts :wwcc_number

  STATUS = ['Stale',
    'Verified',
    'Not Verified',
    'Nominated'].freeze

  validates :email,         presence: true,
                            uniqueness: { case_sensitive: false }
  validates :name,          presence: true,
                            length: { maximum: 40 }
  validates :status,        presence: true,
                            length: { maximum: 12 },
                            inclusion: { in: STATUS }
  validates :address,       length: { maximum: 200 }
  validates :suburb,        length: { maximum: 40 }
  validates :postcode,      numericality: { only_integer: true }
  validates :phone_number,  length: { maximum: 30 }
  validates :gc_reference,  length: { maximum: 40 }
  validates :gc_reference_phone,
                            length: { maximum: 30 }
  validates :wwcc_number,   length: { maximum: 20 }
  validates :group_role,    length: { maximum: 100 }
  validates :years_as_gc,   numericality: { only_integer: true },
                            allow_blank: true

  searchable_by :name, :email

  def role?(role)
    !roles.find_by_name(role.to_s).nil?
  end

  def default_role
    [:admin, :church_rep, :gc, :participant].each do |r|
      return r if role?(r)
    end
  end

  def church_rep_or_gc_role
    [:church_rep, :gc].each do |r|
      return r if role?(r)
    end
  end

  def default_group
    self.groups.first ? self.groups.first.abbr : ""
  end

  def available_groups
    return Group.all.order(:short_name).load if role?(:admin)
    self.groups.order(:short_name)
  end

  def other_groups
    Group.all.order(:short_name).load - self.groups
  end

  def get_reset_password_token
    set_reset_password_token
  end

  protected

  def self.random_password
    User.random_string(10)
  end

  def self.random_string(len)
    # generate a random string consisting of strings and digits
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    string = ''.dup
    1.upto(len) { |_i| string << chars[rand(chars.size - 1)] }
    string
  end
end
