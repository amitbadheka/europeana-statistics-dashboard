# == Schema Information
#
# Table name: core_vizs
#
#  id                         :integer          not null, primary key
#  core_project_id            :integer
#  properties                 :hstore
#  created_at                 :datetime
#  updated_at                 :datetime
#  name                       :string
#  config                     :json
#  created_by                 :integer
#  updated_by                 :integer
#  ref_chart_combination_code :string
#  filter_present             :boolean
#  core_datacast_identifier   :string
#

class Core::Viz < ActiveRecord::Base
  #GEMS
  self.table_name = "core_vizs"
  include WhoDidIt
   

  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  store_accessor :properties, :filter_column_name, :filter_column_d_or_m
  #ASSOCIATIONS
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  belongs_to :ref_chart,class_name: "Ref::Chart",foreign_key: "ref_chart_combination_code", primary_key: "combination_code"
  belongs_to :core_datacast, class_name: "Core::Datacast", foreign_key: "core_datacast_identifier", primary_key: "identifier"
  has_many :views, class_name: "Core::SessionImpl",foreign_key: "core_viz_id", dependent: :destroy
  #VALIDATIONS
  validates :name, uniqueness: {scope: :core_project_id}
  validates :core_datacast_identifier, presence: true
  validate :datacast_output_matches_the_required_conditions?

  #CALLBACKS
  before_create :before_create_set
  after_create :after_create_set

  #SCOPES
  scope :media_type, -> {where("core_vizs.name LIKE '%Media Types'")}
  scope :reusable, -> {where("core_vizs.name LIKE '%Reusables'")}
  scope :top_country, -> {where("core_vizs.name LIKE '%Top Countries'")}
  scope :traffic, -> {where("core_vizs.name LIKE '%Traffic'")}
  #CUSTOM SCOPES
  #FUNCTIONS

  def to_s
    self.name
  end

  def datacast_output_matches_the_required_conditions?
    required = self.required_conditions
    if self.ref_chart.name == "Grid"
      return true
    end
    begin
      datacast = self.core_datacast
      dimension_count = datacast.count("d")
      dimension_names = datacast.column_names("d")
      metric_count = datacast.count("m")
      metric_names = datacast.column_names("m")
      required_metric = required["metrics_required"]
      required_metric_names = required["metrics_alias"]
      required_dimension = required["dimensions_required"]
      required_dimension_names = required["dimensions_alias"]
      if self.filter_present
        if self.filter_column_d_or_m == "m"
          required_metric += 1
          required_metric_names << self.filter_column_name unless self.filter_column_name.nil?
        else
          required_dimension += 1
          required_dimension_names << self.filter_column_name unless self.filter_column_name.nil?
        end
      end
      raise "Metrics does not match the requirements." if metric_count != required_metric
      raise "Dimensions does not match the requirements." if dimension_count != required_dimension
      raise "Metrics name does not match the requirements." if required_metric_names.sort != metric_names.sort
      raise "Dimensions name does not match the requirements." if required_dimension_names.sort != dimension_names.sort
      return true
    rescue => e
      self.errors.add(:core_datacast_identifier, e.to_s)
      return false
    end
  end

  def required_conditions
    return JSON.parse(self.ref_chart.map) if self.ref_chart.present?
    return nil
  end

  def auto_html_div
    return "<div id='#{self.name.parameterize("_")}' data-api='#{self.ref_chart.api}' data-datacast_identifier='#{self.core_datacast_identifier}' class='#{ "One Number indicators" == self.ref_chart.name ? "card_with_value" : "d3-pykcharts"}' data-filter_present='#{self.filter_present}' data-filter_column_name='#{self.filter_column_name}'></div>"
  end

  def self.find_or_create(core_datacast_identifier, name, ref_chart_combination_code,core_project_id,filter_present, filter_column_name, filter_column_d_or_m, validate=true)
    a = where(core_datacast_identifier: core_datacast_identifier, name: name, ref_chart_combination_code: ref_chart_combination_code,core_project_id: core_project_id).first
    if a.blank?
      a = new({core_datacast_identifier: core_datacast_identifier, name: name, ref_chart_combination_code: ref_chart_combination_code,core_project_id: core_project_id,filter_present: filter_present, filter_column_name: filter_column_name, filter_column_d_or_m: filter_column_d_or_m})
      a.save(validate: validate)
    end
    a
  end

  #PRIVATE
  private
  
  def after_create_set
    true
  end

  def before_create_set
    if self.ref_chart.slug == "grid"
      self.config = {
        "data" => {},
        "readOnly" => true,
        "fixedRowsTop" => 0,
        "colHeaders" => [],
        "manualColumnMove" => true,
        "outsideClickDeselects" => false,
        "contextMenu" => false
      }
    end
    unless self.name.present?
      self.name = Core::Viz.last.present? ? "Untitled Visualisation #{Core::Viz.last.id + 1}" : "Untitled Visualisation 1"
    end
    true
  end
end