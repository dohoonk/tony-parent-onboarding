import { gql } from '@apollo/client';

export const MATCH_THERAPISTS = gql`
  mutation MatchTherapists(
    $sessionId: ID!
    $availabilityWindowId: ID!
    $insurancePolicyId: ID
  ) {
    matchTherapists(
      sessionId: $sessionId
      availabilityWindowId: $availabilityWindowId
      insurancePolicyId: $insurancePolicyId
    ) {
      matches {
        id
        name
        email
        phone
        languages
        specialties
        modalities
        bio
        capacityAvailable
        capacityUtilization
        matchScore
        matchRationale
        matchDetails
      }
      errors
    }
  }
`;

export const BOOK_APPOINTMENT = gql`
  mutation BookAppointment($input: BookAppointmentInput!) {
    bookAppointment(input: $input) {
      appointment {
        id
        scheduledAt
        status
      }
      errors
    }
  }
`;

