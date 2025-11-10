FactoryBot.define do
  factory :document do
    version { 1 }
    label { 'privacy_policy' }
    checkboxes { nil }
    version_date { Date.today }
    urls { { 'eng' => 'https://example.com/privacy', 'spa' => 'https://example.com/es/privacy' } }
    names { { 'eng' => 'Privacy Policy', 'spa' => 'Política de Privacidad' } }

    trait :informed_consent do
      label { 'informed_consent' }
      urls { { 'eng' => 'https://example.com/consent', 'spa' => 'https://example.com/es/consent' } }
      names { { 'eng' => 'Informed Consent', 'spa' => 'Consentimiento Informado' } }
    end

    trait :terms_of_service do
      label { 'terms_of_service' }
      urls { { 'eng' => 'https://example.com/terms', 'spa' => 'https://example.com/es/terms' } }
      names { { 'eng' => 'Terms of Service', 'spa' => 'Términos de Servicio' } }
    end
  end
end

