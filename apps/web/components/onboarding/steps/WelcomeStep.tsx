'use client';

import React, { useState } from 'react';
import { useMutation } from '@apollo/client';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Heart, Shield, Clock, Loader2, AlertCircle } from 'lucide-react';
import { SIGNUP, LOGIN } from '@/lib/graphql/mutations';
import { Alert, AlertDescription } from '@/components/ui/alert';

interface WelcomeStepProps {
  onNext: () => void;
}

export const WelcomeStep: React.FC<WelcomeStepProps> = ({ onNext }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [activeTab, setActiveTab] = useState<'login' | 'signup'>('signup');
  
  // Signup form state
  const [signupEmail, setSignupEmail] = useState('');
  const [signupPassword, setSignupPassword] = useState('');
  const [signupFirstName, setSignupFirstName] = useState('');
  const [signupLastName, setSignupLastName] = useState('');
  
  // Login form state
  const [loginEmail, setLoginEmail] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  
  // Error state
  const [error, setError] = useState<string | null>(null);

  const [signup, { loading: signupLoading }] = useMutation(SIGNUP);
  const [login, { loading: loginLoading }] = useMutation(LOGIN);

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    try {
      const { data } = await signup({
        variables: {
          email: signupEmail,
          password: signupPassword,
          firstName: signupFirstName,
          lastName: signupLastName,
        },
      });

      if (data?.signup?.errors?.length > 0) {
        setError(data.signup.errors.join(', '));
        return;
      }

      if (data?.signup?.token) {
        // Store token in localStorage
        localStorage.setItem('auth_token', data.signup.token);
        setIsAuthenticated(true);
        // Small delay to show success, then proceed
        setTimeout(() => {
          onNext();
        }, 500);
      }
    } catch (err: any) {
      setError(err.message || 'Failed to create account. Please try again.');
    }
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    try {
      const { data } = await login({
        variables: {
          email: loginEmail,
          password: loginPassword,
        },
      });

      if (data?.login?.errors?.length > 0) {
        setError(data.login.errors.join(', '));
        return;
      }

      if (data?.login?.token) {
        // Store token in localStorage
        localStorage.setItem('auth_token', data.login.token);
        setIsAuthenticated(true);
        // Small delay to show success, then proceed
        setTimeout(() => {
          onNext();
        }, 500);
      }
    } catch (err: any) {
      setError(err.message || 'Failed to login. Please try again.');
    }
  };

  // If authenticated, show welcome message briefly before proceeding
  if (isAuthenticated) {
    return (
      <div className="space-y-6 text-center">
        <div className="text-2xl font-bold text-green-600">Welcome!</div>
        <p className="text-muted-foreground">Redirecting to onboarding...</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="text-center">
        <h2 className="text-2xl font-bold">Welcome to Daybreak Health</h2>
        <p className="mt-2 text-muted-foreground">
          We&apos;re here to support your child&apos;s mental health journey.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 md:grid-cols-3">
        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col items-center text-center">
              <Heart className="mb-4 h-12 w-12 text-primary" />
              <h3 className="font-semibold">Compassionate Care</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Licensed therapists who specialize in working with children and teens
              </p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col items-center text-center">
              <Shield className="mb-4 h-12 w-12 text-primary" />
              <h3 className="font-semibold">HIPAA Secure</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Your family&apos;s privacy and data security are our top priorities
              </p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col items-center text-center">
              <Clock className="mb-4 h-12 w-12 text-primary" />
              <h3 className="font-semibold">Quick & Easy</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Complete onboarding in about 10 minutes at your own pace
              </p>
            </div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Get Started</CardTitle>
          <CardDescription>
            Create an account or sign in to begin the onboarding process
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Tabs value={activeTab} onValueChange={(v) => {
            setActiveTab(v as 'login' | 'signup');
            setError(null);
          }}>
            <TabsList className="grid w-full grid-cols-2">
              <TabsTrigger value="signup">Sign Up</TabsTrigger>
              <TabsTrigger value="login">Sign In</TabsTrigger>
            </TabsList>
            
            <TabsContent value="signup" className="space-y-4">
              <form onSubmit={handleSignup} className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="signup-first-name">First Name</Label>
                    <Input
                      id="signup-first-name"
                      type="text"
                      required
                      value={signupFirstName}
                      onChange={(e) => setSignupFirstName(e.target.value)}
                      placeholder="John"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="signup-last-name">Last Name</Label>
                    <Input
                      id="signup-last-name"
                      type="text"
                      required
                      value={signupLastName}
                      onChange={(e) => setSignupLastName(e.target.value)}
                      placeholder="Doe"
                    />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="signup-email">Email</Label>
                  <Input
                    id="signup-email"
                    type="email"
                    required
                    value={signupEmail}
                    onChange={(e) => setSignupEmail(e.target.value)}
                    placeholder="john@example.com"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="signup-password">Password</Label>
                  <Input
                    id="signup-password"
                    type="password"
                    required
                    minLength={6}
                    value={signupPassword}
                    onChange={(e) => setSignupPassword(e.target.value)}
                    placeholder="••••••••"
                  />
                </div>
                {error && (
                  <Alert variant="destructive">
                    <AlertCircle className="h-4 w-4" />
                    <AlertDescription>{error}</AlertDescription>
                  </Alert>
                )}
                <Button type="submit" className="w-full" size="lg" disabled={signupLoading}>
                  {signupLoading ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                      Creating Account...
                    </>
                  ) : (
                    'Create Account'
                  )}
                </Button>
              </form>
            </TabsContent>
            
            <TabsContent value="login" className="space-y-4">
              <form onSubmit={handleLogin} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="login-email">Email</Label>
                  <Input
                    id="login-email"
                    type="email"
                    required
                    value={loginEmail}
                    onChange={(e) => setLoginEmail(e.target.value)}
                    placeholder="john@example.com"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="login-password">Password</Label>
                  <Input
                    id="login-password"
                    type="password"
                    required
                    value={loginPassword}
                    onChange={(e) => setLoginPassword(e.target.value)}
                    placeholder="••••••••"
                  />
                </div>
                {error && (
                  <Alert variant="destructive">
                    <AlertCircle className="h-4 w-4" />
                    <AlertDescription>{error}</AlertDescription>
                  </Alert>
                )}
                <Button type="submit" className="w-full" size="lg" disabled={loginLoading}>
                  {loginLoading ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                      Signing In...
                    </>
                  ) : (
                    'Sign In'
                  )}
                </Button>
              </form>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>

      <div className="rounded-md bg-muted p-4">
        <h4 className="font-semibold">What to expect:</h4>
        <ul className="mt-2 space-y-1 text-sm text-muted-foreground">
          <li>• Share basic information about you and your child</li>
          <li>• Tell us about your child&apos;s needs through a guided conversation</li>
          <li>• Complete a brief assessment to help match with the right therapist</li>
          <li>• Provide insurance information (if applicable)</li>
          <li>• Schedule your first session</li>
        </ul>
      </div>
    </div>
  );
};
