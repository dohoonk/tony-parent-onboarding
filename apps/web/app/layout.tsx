import type { Metadata } from "next"
import { Inter } from "next/font/google"
import "./globals.css"
import { ApolloWrapper } from "@/lib/apollo-wrapper"

const inter = Inter({ subsets: ["latin"] })

export const metadata: Metadata = {
  title: "Parent Onboarding - Daybreak Health",
  description: "AI-powered onboarding for parents seeking mental health services",
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.Node
}>) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <ApolloWrapper>
          {children}
        </ApolloWrapper>
      </body>
    </html>
  )
}

