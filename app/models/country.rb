# == Schema Information
#
# Table name: countries
#
#  id     :integer          not null, primary key
#  title  :string(500)
#  status :integer          default(0)
#

class Country < ActiveRecord::Base

  # NOTE: Use this while importing form lagacy DB
  attr_accessible :id, :title, :url_slug
  default_scope { order('title ASC') }
end
