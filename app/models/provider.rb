# == Schema Information
#
# Table name: providers
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#  type            :string           not null
#  name            :string           not null
#  description     :text
#  active          :boolean
#  cached_tag_list :string
#
# Indexes
#
#  index_providers_on_type  (type)
#

class Provider < ActiveRecord::Base
  acts_as_paranoid
  acts_as_taggable

  has_many :answers, as: :answerable
  belongs_to :registered_provider
end