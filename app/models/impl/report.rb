# == Schema Information
#
# Table name: impl_reports
#
#  id                     :integer          not null, primary key
#  impl_aggregation_id    :integer
#  core_template_id       :integer
#  name                   :string
#  slug                   :string
#  html_content           :text
#  variable_object        :json
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  is_autogenerated       :boolean          default(FALSE)
#  core_project_id        :integer          default(1)
#  impl_aggregation_genre :string
#

class Impl::Report < ActiveRecord::Base
  #GEMS
  self.table_name = "impl_reports"

  extend FriendlyId
  friendly_id :name, use: [:slugged, :scoped], scope: [:impl_aggregation, :impl_aggregation_genre]

  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :core_template, class_name: "Core::Template", foreign_key: "core_template_id"
  belongs_to :impl_aggregation, class_name: "Impl::Aggregation", foreign_key: "impl_aggregation_id"
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  #VALIDATIONS
  validates :core_template_id, presence: true, if: "is_autogenerated"
  validates :impl_aggregation_id, presence: true, uniqueness: {scope: [:core_template_id]}, if: "is_autogenerated"
  validates :name, presence: true, uniqueness: {scope: [:core_template_id, :impl_aggregation_id]}
  validates :html_content, presence: true, unless: "is_autogenerated"
  validates :core_project_id, presence: true
  #CALLBACKS
  before_save :before_save_set
  #SCOPES
  scope :manual, -> {where(is_autogenerated: false)}
  #CUSTOM SCOPES
  #FUNCTIONS

  def self.create_or_update(name,aggregation_id, core_template_id, html_content, variable_object,is_autogenerated, slug)
    a = where(name: name, impl_aggregation_id: aggregation_id, core_template_id: core_template_id).first
    if a.blank?
      a = create({name: name, impl_aggregation_id: aggregation_id, core_template_id: core_template_id, html_content: html_content, variable_object: variable_object, is_autogenerated: is_autogenerated, slug: slug})
    else
      a.update_attributes(html_content: html_content, variable_object: variable_object, slug: slug)
    end
    a
  end
  #PRIVATE
  private

  def before_save_set
    self.impl_aggregation_genre = self.impl_aggregation.genre if (self.is_autogenerated and self.impl_aggregation_id.present?)
    true
  end

  def should_generate_new_friendly_id?
    name_changed?
  end
end
