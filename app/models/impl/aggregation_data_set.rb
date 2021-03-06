# == Schema Information
#
# Table name: impl_aggregation_data_sets
#
#  id                  :integer          not null, primary key
#  impl_aggregation_id :integer
#  impl_data_set_id    :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Impl::AggregationDataSet < ActiveRecord::Base
  #GEMS
  self.table_name = "impl_aggregation_data_sets"

  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :impl_aggregation, class_name: "Impl::Aggregation", foreign_key: "impl_aggregation_id"
  belongs_to :impl_data_set, class_name: "Impl::DataSet", foreign_key: "impl_data_set_id"
  #VALIDATIONS
  validates :impl_data_set_id, presence: :true
  validates :impl_aggregation_id, presence: :true, uniqueness: {scope: :impl_data_set_id}

  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  #PRIVATE
end
