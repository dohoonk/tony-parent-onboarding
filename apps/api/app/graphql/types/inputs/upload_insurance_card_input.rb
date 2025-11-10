module Types
  module Inputs
    class UploadInsuranceCardInput < Types::BaseInputObject
      description "Input for uploading an insurance card"

      argument :session_id, ID, required: true, description: "ID of the onboarding session"
      argument :front_image_url, String, required: true, description: "S3 URL of front image"
      argument :back_image_url, String, required: false, description: "S3 URL of back image"
    end
  end
end

