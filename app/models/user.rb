# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_and_belongs_to_many :roles
  has_and_belongs_to_many :groups

  validates :email,     presence: true,
                        uniqueness: { case_sensitive: false }
  
  before_create :set_default_role

  def role?(role)
    !roles.find_by_name(role.to_s).nil?
  end

  def default_role
    [:admin, :church_rep, :gc, :participant].each do |r|
      return r if role?(r)
    end
  end

  def available_groups
    return Group.all.load if role?(:admin)
    self.groups
  end

  def other_groups
    Group.all.load - self.groups
  end

  private

  def set_default_role
    self.roles << Role.find_by_name('admin')
  end
end
