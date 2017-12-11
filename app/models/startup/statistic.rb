class Startup::Statistic < ActiveRecord::Base
  attr_accessible :startup_id, :followers_count
  belongs_to :startup

end
