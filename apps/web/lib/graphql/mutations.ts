import { gql } from '@apollo/client';

export const SIGNUP = gql`
  mutation Signup($email: String!, $password: String!, $firstName: String!, $lastName: String!) {
    signup(email: $email, password: $password, firstName: $firstName, lastName: $lastName) {
      parent {
        id
        email
        firstName
        lastName
      }
      token
      errors
    }
  }
`;

export const LOGIN = gql`
  mutation Login($email: String!, $password: String!) {
    login(email: $email, password: $password) {
      parent {
        id
        email
        firstName
        lastName
      }
      token
      errors
    }
  }
`;

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

export const UPLOAD_INSURANCE_CARD = gql`
  mutation UploadInsuranceCard($input: UploadInsuranceCardInput!) {
    uploadInsuranceCard(input: $input) {
      insuranceCard {
        id
        extractedData
      }
      errors
    }
  }
`;

