module Types
  module Inputs
    class CreateStudentInput < Types::BaseInputObject
      description "Input for creating a new student"

      argument :first_name, String, required: true, description: "Student's first name"
      argument :last_name, String, required: true, description: "Student's last name"
      argument :date_of_birth, GraphQL::Types::ISO8601Date, required: true, description: "Student's date of birth"
      argument :grade, String, required: false, description: "Student's grade"
      argument :school, String, required: false, description: "Student's school"
      argument :language, String, required: false, description: "Student's preferred language (default: 'en')"
    end
  end
end




