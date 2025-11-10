import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <Card className="w-[600px]">
        <CardHeader>
          <CardTitle>Parent Onboarding AI</CardTitle>
          <CardDescription>
            Welcome to Daybreak Health's AI-powered onboarding experience
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <p className="text-sm text-muted-foreground">
              We&apos;re here to guide you through understanding your child&apos;s mental health needs 
              and connecting you with the right support.
            </p>
            <Button className="w-full" size="lg">
              Begin Onboarding
            </Button>
          </div>
        </CardContent>
      </Card>
    </main>
  )
}

