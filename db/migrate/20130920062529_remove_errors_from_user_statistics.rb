class RemoveErrorsFromUserStatistics < ActiveRecord::Migration
  def change
  	remove_column :cronjobs, :errors
  end
end
