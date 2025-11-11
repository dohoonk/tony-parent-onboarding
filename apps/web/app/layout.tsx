import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { SkipLink } from "@/components/onboarding/SkipLink";
import { SupportChat } from "@/components/support/SupportChat";
import { ApolloWrapper } from "@/lib/apollo-wrapper";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Daybreak Health - Parent Onboarding",
  description: "Complete your child's mental health onboarding",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <ApolloWrapper>
          <SkipLink href="#main-content">Skip to main content</SkipLink>
          <main id="main-content" tabIndex={-1}>
            {children}
          </main>
          <SupportChat />
        </ApolloWrapper>
      </body>
    </html>
  );
}
