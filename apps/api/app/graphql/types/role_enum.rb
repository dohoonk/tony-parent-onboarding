module Types
  class RoleEnum < Types::BaseEnum
    description "User roles in the system"

    value "PARENT", "Parent or guardian user", value: "parent"
    value "STAFF", "Staff member", value: "staff"
    value "THERAPIST", "Licensed therapist", value: "therapist"
    value "ADMIN", "System administrator", value: "admin"
  end
end

