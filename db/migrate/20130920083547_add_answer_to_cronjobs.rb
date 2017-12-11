class AddAnswerToCronjobs < ActiveRecord::Migration
  def change
    add_column :cronjobs, :answer, :string
  end
end
