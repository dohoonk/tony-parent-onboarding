module Types
  class MessageRoleEnum < Types::BaseEnum
    description "Role of a message in the intake conversation"

    value "USER", "Message from the parent", value: "user"
    value "ASSISTANT", "Message from the AI assistant", value: "assistant"
    value "SYSTEM", "System message", value: "system"
  end
end

