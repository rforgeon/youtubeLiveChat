class CreateYoutubeHandlers < ActiveRecord::Migration[5.0]
  def change
    create_table :youtube_handlers do |t|
      t.string :chat_id
      t.string :script
      t.string :name

      t.timestamps
    end
  end
end
