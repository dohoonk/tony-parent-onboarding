module Types
  class OrganizationKindEnum < Types::BaseEnum
    value "DISTRICT", "A school district", value: "district"
    value "SCHOOL", "A school within a district", value: "school"
  end
end

