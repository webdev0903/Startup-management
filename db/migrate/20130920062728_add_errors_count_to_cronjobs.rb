class AddErrorsCountToCronjobs < ActiveRecord::Migration
  def change
    add_column :cronjobs, :errors_count, :integer
  end
end
