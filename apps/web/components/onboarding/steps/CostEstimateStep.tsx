'use client';

import React, { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Loader2, DollarSign, AlertCircle, Info } from 'lucide-react';

interface CostEstimateStepProps {
  onNext: () => void;
  onPrev: () => void;
  sessionId?: string;
}

export const CostEstimateStep: React.FC<CostEstimateStepProps> = ({
  onNext,
  onPrev,
  sessionId
}) => {
  const [costEstimate, setCostEstimate] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (sessionId) {
      loadCostEstimate();
    }
  }, [sessionId]);

  const loadCostEstimate = async () => {
    setIsLoading(true);
    setError(null);

    try {
      // TODO: Call GraphQL mutation to get cost estimate
      // For now, simulate
      await new Promise((resolve) => setTimeout(resolve, 1000));
      
      // Mock estimate
      setCostEstimate({
        min_cost: 20,
        max_cost: 50,
        currency: 'USD',
        payer_name: 'Blue Cross Blue Shield',
        plan_type: 'PPO'
      });
    } catch (err) {
      setError('Failed to load cost estimate');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-6">
        <Card className="border-destructive">
          <CardHeader>
            <div className="flex items-center gap-2">
              <AlertCircle className="h-5 w-5 text-destructive" />
              <CardTitle>Unable to Estimate Cost</CardTitle>
            </div>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground mb-4">{error}</p>
            <Button onClick={onNext} variant="outline">
              Continue Anyway
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="rounded-md border bg-muted/50 p-4">
        <h3 className="font-semibold">Cost Estimate</h3>
        <p className="mt-1 text-sm text-muted-foreground">
          Based on your insurance information, here&apos;s an estimate of your out-of-pocket costs.
        </p>
      </div>

      {costEstimate && (
        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <DollarSign className="h-5 w-5 text-primary" />
              <CardTitle>Estimated Cost Per Session</CardTitle>
            </div>
            <CardDescription>
              Insurance: {costEstimate.payer_name} ({costEstimate.plan_type})
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="text-center py-6">
              <div className="text-4xl font-bold text-primary mb-2">
                ${costEstimate.min_cost} - ${costEstimate.max_cost}
              </div>
              <p className="text-sm text-muted-foreground">per session</p>
            </div>

            <div className="rounded-md bg-blue-50 border border-blue-200 p-4">
              <div className="flex items-start gap-2">
                <Info className="h-5 w-5 text-blue-600 mt-0.5" />
                <div className="flex-1">
                  <p className="text-sm font-medium text-blue-900 mb-1">
                    This is a provisional estimate
                  </p>
                  <p className="text-xs text-blue-700">
                    Your actual out-of-pocket cost may vary based on your specific plan benefits, 
                    deductible status, and copay structure. Final costs will be confirmed when you 
                    book your first appointment.
                  </p>
                </div>
              </div>
            </div>

            <div className="rounded-md bg-muted p-4">
              <p className="text-xs text-muted-foreground">
                <strong>Note:</strong> This estimate is based on typical costs for your insurance 
                plan type. Your actual costs depend on your specific plan details, whether you&apos;ve 
                met your deductible, and your copay/coinsurance structure. We&apos;ll verify your exact 
                benefits before your first session.
              </p>
            </div>
          </CardContent>
        </Card>
      )}

      <div className="flex flex-col-reverse gap-3 sm:flex-row sm:justify-between">
        <Button type="button" variant="outline" onClick={onPrev} className="w-full sm:w-auto">
          Back
        </Button>
        <Button onClick={onNext} className="w-full sm:w-auto">
          Continue to Scheduling
        </Button>
      </div>
    </div>
  );
};

