module Types
  class AppointmentStatusEnum < Types::BaseEnum
    description "Status of an appointment"

    value "SCHEDULED", "Appointment is scheduled", value: "scheduled"
    value "CONFIRMED", "Appointment is confirmed", value: "confirmed"
    value "COMPLETED", "Appointment was completed", value: "completed"
    value "CANCELLED", "Appointment was cancelled", value: "cancelled"
    value "NO_SHOW", "Patient did not show up", value: "no_show"
  end
end

