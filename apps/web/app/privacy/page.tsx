import React from 'react';

export default function PrivacyPage() {
  return (
    <div className="container mx-auto max-w-4xl px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Privacy Policy</h1>
      
      <div className="prose prose-slate max-w-none">
        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Our Commitment to Your Privacy</h2>
          <p className="mb-4">
            Daybreak Health is committed to protecting your family&apos;s privacy and the confidentiality 
            of your protected health information (PHI). This policy outlines how we collect, use, and 
            safeguard your information.
          </p>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Information We Collect</h2>
          <p className="mb-4">We collect information necessary to provide mental health services, including:</p>
          <ul className="list-disc pl-6 mb-4 space-y-2">
            <li>Personal identification information (name, date of birth, contact information)</li>
            <li>Health information (symptoms, diagnoses, treatment history)</li>
            <li>Insurance information for billing purposes</li>
            <li>Educational records (with your written consent)</li>
            <li>Communication preferences and consent forms</li>
          </ul>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">How We Use Your Information</h2>
          <p className="mb-4">We use your information to:</p>
          <ul className="list-disc pl-6 mb-4 space-y-2">
            <li>Provide mental health treatment and services</li>
            <li>Coordinate care with other healthcare providers (with your consent)</li>
            <li>Process insurance claims and handle billing</li>
            <li>Communicate with you about appointments and services</li>
            <li>Comply with legal and regulatory requirements</li>
            <li>Improve our services and conduct quality assurance</li>
          </ul>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Information Sharing</h2>
          <p className="mb-4">
            We may share your information with the following parties, always in compliance with HIPAA:
          </p>
          <ul className="list-disc pl-6 mb-4 space-y-2">
            <li><strong>Your Insurance Company:</strong> For billing and claims processing</li>
            <li><strong>Other Healthcare Providers:</strong> With your written consent for care coordination</li>
            <li><strong>Schools:</strong> With your written consent and as clinically appropriate</li>
            <li><strong>Legal Authorities:</strong> When required by law (court orders, subpoenas)</li>
            <li><strong>Emergency Situations:</strong> When there is risk of harm to self or others</li>
          </ul>
          <p className="mb-4">
            We do not sell your information to third parties for marketing purposes.
          </p>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Your Privacy Rights</h2>
          <p className="mb-4">Under HIPAA, you have the right to:</p>
          <ul className="list-disc pl-6 mb-4 space-y-2">
            <li>Access your health records and request copies</li>
            <li>Request corrections to inaccurate information</li>
            <li>Request restrictions on how we use or disclose your information</li>
            <li>Receive an accounting of disclosures</li>
            <li>Request confidential communications</li>
            <li>File a complaint if you believe your privacy rights have been violated</li>
          </ul>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Security Measures</h2>
          <p className="mb-4">
            We use industry-standard security measures to protect your information:
          </p>
          <ul className="list-disc pl-6 mb-4 space-y-2">
            <li>Encryption of data in transit and at rest</li>
            <li>Secure servers and databases</li>
            <li>Access controls and authentication</li>
            <li>Regular security audits and updates</li>
            <li>Staff training on privacy and security</li>
          </ul>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">HIPAA Compliance</h2>
          <p className="mb-4">
            Daybreak Health complies with the Health Insurance Portability and Accountability Act (HIPAA) 
            and maintains strict confidentiality standards. We are a covered entity under HIPAA and follow 
            all applicable privacy and security regulations.
          </p>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Contact Us</h2>
          <p className="mb-4">
            If you have questions about this Privacy Policy or wish to exercise your privacy rights, 
            please contact us:
          </p>
          <div className="bg-muted p-4 rounded-md">
            <p><strong>Privacy Officer</strong></p>
            <p>Daybreak Health</p>
            <p>Email: privacy@daybreakhealth.com</p>
            <p>Phone: (555) 123-4567</p>
          </div>
        </section>

        <section className="mb-8">
          <p className="text-sm text-muted-foreground">
            <strong>Last Updated:</strong> November 2024
          </p>
          <p className="text-sm text-muted-foreground">
            <strong>Note:</strong> This is an example privacy policy for development and testing purposes. 
            In production, use actual legal documents reviewed by legal counsel.
          </p>
        </section>
      </div>
    </div>
  );
}

