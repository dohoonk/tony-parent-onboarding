import React from 'react';

export default function TermsPage() {
  return (
    <div className="container mx-auto max-w-4xl px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Terms of Service</h1>
      
      <div className="prose prose-slate max-w-none">
        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Agreement to Terms</h2>
          <p className="mb-4">
            By accessing and using Daybreak Health&apos;s services, you agree to be bound by these Terms 
            of Service. If you do not agree to these terms, please do not use our services.
          </p>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Service Description</h2>
          <p className="mb-4">
            Daybreak Health provides mental health services for children and adolescents, including:
          </p>
          <ul className="list-disc pl-6 mb-4 space-y-2">
            <li>Individual and family therapy sessions</li>
            <li>Psychological assessments and evaluations</li>
            <li>Treatment planning and coordination</li>
            <li>Educational and support resources</li>
            <li>Care coordination with schools and other providers</li>
          </ul>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Eligibility and Requirements</h2>
          <p className="mb-4">To use our services, you must:</p>
          <ul className="list-disc pl-6 mb-4 space-y-2">
            <li>Be a parent or legal guardian of a child seeking services</li>
            <li>Meet clinical criteria for services</li>
            <li>Have appropriate insurance coverage or payment arrangements</li>
            <li>Complete the onboarding process</li>
            <li>Provide accurate and complete information</li>
            <li>Be at least 18 years of age (for parents/guardians)</li>
          </ul>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">User Responsibilities</h2>
          <p className="mb-4">You agree to:</p>
          <ul className="list-disc pl-6 mb-4 space-y-2">
            <li>Provide accurate, current, and complete information</li>
            <li>Attend scheduled appointments or provide adequate notice for cancellations (24+ hours)</li>
            <li>Follow treatment recommendations and participate actively in your child&apos;s care</li>
            <li>Pay for services as agreed, including copays, deductibles, and non-covered services</li>
            <li>Respect the therapeutic relationship and maintain appropriate boundaries</li>
            <li>Notify us immediately of any changes to insurance, contact information, or emergency contacts</li>
            <li>Not share login credentials or allow unauthorized access to your account</li>
          </ul>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Appointment and Cancellation Policy</h2>
          <ul className="list-disc pl-6 mb-4 space-y-2">
            <li>Appointments must be cancelled at least <strong>24 hours in advance</strong></li>
            <li>Late cancellations (less than 24 hours) may be subject to a cancellation fee</li>
            <li>No-shows may be charged the full session fee</li>
            <li>Repeated cancellations or no-shows may result in service limitations or termination</li>
            <li>We reserve the right to reschedule or cancel appointments with appropriate notice</li>
          </ul>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Payment Terms</h2>
          <ul className="list-disc pl-6 mb-4 space-y-2">
            <li>Payment is due at the time of service or as otherwise agreed in writing</li>
            <li>We will submit insurance claims on your behalf</li>
            <li>You are responsible for any amounts not covered by insurance, including:
              <ul className="list-circle pl-6 mt-2 space-y-1">
                <li>Copays and coinsurance</li>
                <li>Deductibles</li>
                <li>Non-covered services</li>
                <li>Out-of-network charges (if applicable)</li>
              </ul>
            </li>
            <li>Outstanding balances may result in service suspension</li>
            <li>We accept major credit cards, debit cards, and HSA/FSA cards</li>
            <li>Payment plans may be available for qualifying circumstances</li>
          </ul>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Service Availability</h2>
          <p className="mb-4">
            While we strive to provide consistent, high-quality services, we cannot guarantee:
          </p>
          <ul className="list-disc pl-6 mb-4 space-y-2">
            <li>Specific therapist assignments or availability</li>
            <li>Immediate availability of appointments</li>
            <li>Specific treatment outcomes or results</li>
            <li>Uninterrupted service availability (due to technical issues, emergencies, etc.)</li>
          </ul>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Limitation of Liability</h2>
          <p className="mb-4">
            To the maximum extent permitted by law, Daybreak Health is not liable for:
          </p>
          <ul className="list-disc pl-6 mb-4 space-y-2">
            <li>Treatment outcomes or results</li>
            <li>Decisions made by third parties (schools, courts, insurance companies, etc.)</li>
            <li>Technical issues with the platform or website</li>
            <li>Acts beyond our reasonable control (natural disasters, pandemics, etc.)</li>
            <li>Indirect, incidental, or consequential damages</li>
          </ul>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Termination of Services</h2>
          <p className="mb-4">
            Either party may terminate services with appropriate notice:
          </p>
          <ul className="list-disc pl-6 mb-4 space-y-2">
            <li><strong>By You:</strong> You may discontinue services at any time by providing written notice</li>
            <li><strong>By Us:</strong> We may terminate services for:
              <ul className="list-circle pl-6 mt-2 space-y-1">
                <li>Non-payment or payment issues</li>
                <li>Repeated no-shows or cancellations</li>
                <li>Inappropriate behavior or boundary violations</li>
                <li>Clinical reasons (e.g., needs exceed our scope of practice)</li>
                <li>Violation of these terms</li>
              </ul>
            </li>
            <li>We will provide referrals and transition support when clinically appropriate</li>
            <li>You remain responsible for any outstanding balances</li>
          </ul>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Intellectual Property</h2>
          <p className="mb-4">
            All content, materials, and intellectual property on the Daybreak Health platform are owned 
            by Daybreak Health or its licensors. You may not reproduce, distribute, or create derivative 
            works without written permission.
          </p>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Dispute Resolution</h2>
          <p className="mb-4">
            Any disputes arising from these terms or our services will be resolved through:
          </p>
          <ol className="list-decimal pl-6 mb-4 space-y-2">
            <li>Good faith negotiation</li>
            <li>Mediation (if negotiation fails)</li>
            <li>Binding arbitration (if mediation fails)</li>
          </ol>
          <p className="mb-4">
            You waive your right to a jury trial and to participate in class action lawsuits.
          </p>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Changes to Terms</h2>
          <p className="mb-4">
            We reserve the right to modify these terms at any time. You will be notified of significant 
            changes via email or through the platform. Continued use of services after changes constitutes 
            acceptance of the new terms.
          </p>
        </section>

        <section className="mb-8">
          <h2 className="text-2xl font-semibold mb-4">Contact Information</h2>
          <div className="bg-muted p-4 rounded-md">
            <p><strong>Daybreak Health</strong></p>
            <p>Email: support@daybreakhealth.com</p>
            <p>Phone: (555) 123-4567</p>
            <p>Address: [Your Business Address]</p>
          </div>
        </section>

        <section className="mb-8">
          <p className="text-sm text-muted-foreground">
            <strong>Last Updated:</strong> November 2024
          </p>
          <p className="text-sm text-muted-foreground">
            <strong>Note:</strong> This is an example Terms of Service for development and testing purposes. 
            In production, use actual legal documents reviewed by legal counsel.
          </p>
        </section>
      </div>
    </div>
  );
}

