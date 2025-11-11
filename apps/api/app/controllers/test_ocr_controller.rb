class TestOcrController < ApplicationController
  # API controllers don't have CSRF protection by default

  # Test endpoint to validate OpenAI API key
  # Usage: GET /test_ocr/validate_key
  def validate_key
    Rails.logger.info("=" * 80)
    Rails.logger.info("VALIDATING OPENAI API KEY")
    Rails.logger.info("=" * 80)

    begin
      service = OpenaiService.new
      
      # Make a simple test API call
      test_response = service.chat_completion(
        messages: [
          {
            role: 'user',
            content: 'Say "API key is valid" if you can read this.'
          }
        ],
        system_prompt: 'You are a helpful assistant.'
      )

      Rails.logger.info("=" * 80)
      Rails.logger.info("✅ OPENAI API KEY IS VALID")
      Rails.logger.info("Response: #{test_response[:content]}")
      Rails.logger.info("=" * 80)

      render json: {
        valid: true,
        message: "API key is valid",
        response: test_response[:content],
        usage: test_response[:usage]
      }
    rescue OpenaiService::ServiceError => e
      Rails.logger.error("=" * 80)
      Rails.logger.error("❌ OPENAI API KEY VALIDATION FAILED")
      Rails.logger.error("Error: #{e.message}")
      Rails.logger.error("=" * 80)

      render json: {
        valid: false,
        error: e.message,
        message: "API key is invalid or missing"
      }, status: :unauthorized
    rescue StandardError => e
      Rails.logger.error("=" * 80)
      Rails.logger.error("❌ UNEXPECTED ERROR DURING VALIDATION")
      Rails.logger.error("Error: #{e.class.name} - #{e.message}")
      Rails.logger.error("Backtrace:")
      Rails.logger.error(e.backtrace.join("\n"))
      Rails.logger.error("=" * 80)

      render json: {
        valid: false,
        error: e.message,
        error_class: e.class.name,
        message: "Unexpected error occurred"
      }, status: :internal_server_error
    end
  end

  # Test endpoint to manually trigger OCR extraction
  # Usage: POST /test_ocr with JSON body:
  # { "front_image_url": "https://...", "back_image_url": "https://..." }
  def extract
    front_url = params[:front_image_url]
    back_url = params[:back_image_url]

    unless front_url.present?
      render json: { error: "front_image_url is required" }, status: :bad_request
      return
    end

    Rails.logger.info("=" * 80)
    Rails.logger.info("TEST OCR EXTRACTION REQUEST")
    Rails.logger.info("Front URL: #{front_url}")
    Rails.logger.info("Back URL: #{back_url || 'N/A'}")
    Rails.logger.info("=" * 80)

    begin
      result = InsuranceOcrService.extract(
        front_image_url: front_url,
        back_image_url: back_url
      )

      Rails.logger.info("=" * 80)
      Rails.logger.info("TEST OCR EXTRACTION SUCCESS")
      Rails.logger.info("Extracted fields: #{result[:extracted_data].keys.join(', ')}")
      Rails.logger.info("Full result: #{result.inspect}")
      Rails.logger.info("=" * 80)

      render json: {
        success: true,
        extracted_data: result[:extracted_data],
        confidence_scores: result[:confidence_scores]
      }
    rescue StandardError => e
      Rails.logger.error("=" * 80)
      Rails.logger.error("TEST OCR EXTRACTION FAILED")
      Rails.logger.error("Error: #{e.class.name} - #{e.message}")
      Rails.logger.error("Backtrace:")
      Rails.logger.error(e.backtrace.join("\n"))
      Rails.logger.error("=" * 80)

      render json: {
        success: false,
        error: e.message,
        error_class: e.class.name
      }, status: :internal_server_error
    end
  end
end

