module Mutations
  class CreateStudent < BaseMutation
    description "Create a new student for the current parent"

    argument :input, Types::Inputs::CreateStudentInput, required: true

    field :student, Types::StudentType, null: true
    field :errors, [String], null: false

    def resolve(input:)
      parent = context[:current_user]
      
      unless parent
        return { student: nil, errors: ["Authentication required"] }
      end

      # Create new student
      student = parent.students.new(
        first_name: input.first_name,
        last_name: input.last_name,
        date_of_birth: input.date_of_birth,
        grade: input.grade,
        school: input.school,
        language: input.language || 'en'
      )

      if student.save
        # Log audit trail
        AuditLog.log_access(
          actor: parent,
          action: 'write',
          entity: student,
          after: student.attributes
        )

        { student: student, errors: [] }
      else
        { student: nil, errors: student.errors.full_messages }
      end
    end
  end
end


