'use client';

import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Mail, MessageSquare, Loader2, CheckCircle2 } from 'lucide-react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';

interface MagicLinkRequestProps {
  onLinkSent: (method: 'email' | 'sms', identifier: string) => void;
}

export const MagicLinkRequest: React.FC<MagicLinkRequestProps> = ({ onLinkSent }) => {
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [sentMethod, setSentMethod] = useState<'email' | 'sms' | null>(null);
  const [sentIdentifier, setSentIdentifier] = useState<string>('');

  const handleEmailSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setIsLoading(true);

    try {
      // TODO: Call GraphQL mutation to send magic link via email
      // const result = await sendMagicLinkEmail({ email });
      
      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      setIsSuccess(true);
      setSentMethod('email');
      setSentIdentifier(email);
      onLinkSent('email', email);
    } catch (err) {
      setError('Failed to send magic link. Please try again.');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSmsSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setIsLoading(true);

    try {
      // TODO: Call GraphQL mutation to send magic link via SMS
      // const result = await sendMagicLinkSms({ phone });
      
      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      setIsSuccess(true);
      setSentMethod('sms');
      setSentIdentifier(phone);
      onLinkSent('sms', phone);
    } catch (err) {
      setError('Failed to send magic link. Please try again.');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  if (isSuccess) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <CheckCircle2 className="h-5 w-5 text-green-600" />
            Magic Link Sent!
          </CardTitle>
          <CardDescription>
            We've sent a secure link to{' '}
            {sentMethod === 'email' ? (
              <strong>{sentIdentifier}</strong>
            ) : (
              <strong>{sentIdentifier}</strong>
            )}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="rounded-md bg-muted p-4">
              <p className="text-sm">
                <strong>What's next?</strong>
              </p>
              <ul className="mt-2 list-disc space-y-1 pl-5 text-sm text-muted-foreground">
                <li>Check your {sentMethod === 'email' ? 'email inbox' : 'text messages'}</li>
                <li>Click the secure link to resume your onboarding</li>
                <li>The link expires in 15 minutes for security</li>
              </ul>
            </div>
            <p className="text-xs text-muted-foreground">
              Didn't receive it? Check your spam folder or{' '}
              <button
                onClick={() => {
                  setIsSuccess(false);
                  setError(null);
                }}
                className="text-primary underline"
              >
                try again
              </button>
            </p>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Resume Your Onboarding</CardTitle>
        <CardDescription>
          Enter your email or phone number to receive a secure link to continue where you left off
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Tabs defaultValue="email" className="w-full">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="email" className="flex items-center gap-2">
              <Mail className="h-4 w-4" />
              Email
            </TabsTrigger>
            <TabsTrigger value="sms" className="flex items-center gap-2">
              <MessageSquare className="h-4 w-4" />
              SMS
            </TabsTrigger>
          </TabsList>

          <TabsContent value="email" className="mt-4">
            <form onSubmit={handleEmailSubmit} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="resume-email">Email Address</Label>
                <Input
                  id="resume-email"
                  type="email"
                  placeholder="you@example.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  disabled={isLoading}
                />
              </div>
              {error && (
                <div className="rounded-md bg-destructive/10 p-3 text-sm text-destructive" role="alert">
                  {error}
                </div>
              )}
              <Button type="submit" className="w-full" disabled={isLoading}>
                {isLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                Send Magic Link
              </Button>
            </form>
          </TabsContent>

          <TabsContent value="sms" className="mt-4">
            <form onSubmit={handleSmsSubmit} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="resume-phone">Phone Number</Label>
                <Input
                  id="resume-phone"
                  type="tel"
                  placeholder="(555) 123-4567"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  required
                  disabled={isLoading}
                />
                <p className="text-xs text-muted-foreground">
                  We'll send you a text message with a secure link
                </p>
              </div>
              {error && (
                <div className="rounded-md bg-destructive/10 p-3 text-sm text-destructive" role="alert">
                  {error}
                </div>
              )}
              <Button type="submit" className="w-full" disabled={isLoading}>
                {isLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                Send Magic Link
              </Button>
            </form>
          </TabsContent>
        </Tabs>
      </CardContent>
    </Card>
  );
};

