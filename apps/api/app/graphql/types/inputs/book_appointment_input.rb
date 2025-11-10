module Types
  module Inputs
    class BookAppointmentInput < Types::BaseInputObject
      description "Input for booking a therapy appointment"

      argument :session_id, ID, required: true, description: "ID of the onboarding session"
      argument :therapist_id, ID, required: true, description: "ID of the therapist"
      argument :scheduled_at, GraphQL::Types::ISO8601DateTime, required: true, description: "Appointment date/time"
      argument :duration_minutes, Integer, required: false, description: "Duration in minutes (default: 50)"
    end
  end
end

