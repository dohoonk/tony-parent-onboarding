class ChangeInsuranceCardImageUrlsToText < ActiveRecord::Migration[8.0]
  def change
    # Change front_image_url and back_image_url from string (255 char limit) to text (unlimited)
    # This allows storing base64 data URLs which can be very long
    change_column :insurance_cards, :front_image_url, :text
    change_column :insurance_cards, :back_image_url, :text
  end
end
