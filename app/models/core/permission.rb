# == Schema Information
#
# Table name: core_permissions
#
#  id              :integer          not null, primary key
#  account_id      :integer
#  organisation_id :integer
#  role            :string(255)
#  email           :string(255)
#  status          :string(255)
#  invited_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  core_team_id    :integer
#  is_owner_team   :boolean
#  created_by      :integer
#  updated_by      :integer
#

# LOCKING this class. Do not change. 
# Module: Access-Control
# Author: Ritvvij Parrikh

class Core::Permission < ActiveRecord::Base

  #GEMS
  self.table_name = "core_permissions"
  include WhoDidIt
   
   
  
  #CONSTANTS  
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :account
  belongs_to :organisation, class_name: "Account", foreign_key: "organisation_id"
  belongs_to :core_team, class_name: "Core::Team", foreign_key: "core_team_id"
  belongs_to :core_account_email,class_name: "Core::AccountEmail", foreign_key: "email",primary_key: "email"
  has_many :core_team_projects, class_name: "Core::TeamProject", through: :core_team
  has_many :core_projects, class_name: "Core::Project", through: :core_team_projects
  
  #VALIDATIONS
  validates :email, presence: true, format: {with: Constants::EMAIL}
  validates :role, presence: true
  validates :organisation_id, presence: true
  validates :account_id, presence: true, on: :update
  
  #CALLBACKS
  before_create :before_create_set
  
  #SCOPES
  scope :owners, -> { where(role: Constants::ROLE_O) }
  scope :collaborators, -> { where(role: Constants::ROLE_C) }
  scope :invited, -> { where("account_id IS NULL") }
  scope :accepted, -> { where("account_id IS NOT NULL") }
  
  #CUSTOM SCOPES
  
  def set_account_id_if_email_found
    core_account_email = Core::AccountEmail.where(email: self.email).first
    if core_account_email.present?
      ac = core_account_email.account
      if ac.present?
        self.account_id = ac.id
        self.status = Constants::STATUS_A
      end
    end
  end
  
  #FUNCTIONS
  
  def to_s
    self.account_id.present? ? self.account.username : self.email
  end
  
  #PRIVATE
  
  private
  
  def before_create_set
    self.role = Constants::ROLE_C   if self.role.blank?
    self.status =  Constants::STATUS_A if self.status.blank?
    self.invited_at = Time.now
    if self.core_team.present? and self.is_owner_team.blank?
      self.is_owner_team = self.core_team.is_owner_team
    end
    true
  end
    
end
