'use client';

import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, LineChart, Line } from 'recharts';

interface FunnelData {
  step: string;
  started: number;
  completed: number;
  dropOff: number;
  avgTime: number;
}

export const FunnelDashboard: React.FC = () => {
  const [funnelData, setFunnelData] = useState<FunnelData[]>([]);
  const [completionRate, setCompletionRate] = useState(0);
  const [avgCompletionTime, setAvgCompletionTime] = useState(0);
  const [dropOffPoints, setDropOffPoints] = useState<Record<string, number>>({});

  useEffect(() => {
    loadFunnelData();
  }, []);

  const loadFunnelData = async () => {
    // TODO: Fetch from GraphQL API or analytics service
    // Mock data for now
    const mockData: FunnelData[] = [
      { step: 'Welcome', started: 1000, completed: 950, dropOff: 50, avgTime: 30 },
      { step: 'Parent Info', started: 950, completed: 900, dropOff: 50, avgTime: 120 },
      { step: 'Student Info', started: 900, completed: 850, dropOff: 50, avgTime: 180 },
      { step: 'Consent', started: 850, completed: 800, dropOff: 50, avgTime: 60 },
      { step: 'AI Intake', started: 800, completed: 750, dropOff: 50, avgTime: 600 },
      { step: 'Screener', started: 750, completed: 700, dropOff: 50, avgTime: 300 },
      { step: 'Insurance', started: 700, completed: 600, dropOff: 100, avgTime: 420 },
      { step: 'Scheduling', started: 600, completed: 550, dropOff: 50, avgTime: 480 },
      { step: 'Summary', started: 550, completed: 550, dropOff: 0, avgTime: 60 }
    ];

    setFunnelData(mockData);
    setCompletionRate((550 / 1000) * 100);
    setAvgCompletionTime(2250); // Total average time in seconds
    setDropOffPoints({
      'Insurance': 100,
      'Welcome': 50,
      'Parent Info': 50,
      'Student Info': 50,
      'Consent': 50,
      'AI Intake': 50,
      'Screener': 50,
      'Scheduling': 50
    });
  };

  return (
    <div className="space-y-6 p-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Onboarding Funnel Analytics</h1>
        <p className="text-muted-foreground mt-2">
          Track onboarding metrics, drop-off points, and completion rates
        </p>
      </div>

      {/* Key Metrics */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Completion Rate</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{completionRate.toFixed(1)}%</div>
            <p className="text-xs text-muted-foreground mt-1">
              {550} of {1000} users completed
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Avg Completion Time</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {Math.floor(avgCompletionTime / 60)} min
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              Average time to complete onboarding
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Total Drop-offs</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">450</div>
            <p className="text-xs text-muted-foreground mt-1">
              Users who didn&apos;t complete
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Funnel Chart */}
      <Card>
        <CardHeader>
          <CardTitle>Onboarding Funnel</CardTitle>
          <CardDescription>User progression through each step</CardDescription>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={400}>
            <BarChart data={funnelData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="step" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="started" fill="#8884d8" name="Started" />
              <Bar dataKey="completed" fill="#82ca9d" name="Completed" />
              <Bar dataKey="dropOff" fill="#ffc658" name="Dropped Off" />
            </BarChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      {/* Drop-off Points */}
      <Card>
        <CardHeader>
          <CardTitle>Drop-off Points</CardTitle>
          <CardDescription>Where users are leaving the onboarding flow</CardDescription>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={Object.entries(dropOffPoints).map(([step, count]) => ({ step, count }))}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="step" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="count" fill="#ef4444" />
            </BarChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      {/* Time per Step */}
      <Card>
        <CardHeader>
          <CardTitle>Average Time per Step</CardTitle>
          <CardDescription>Time spent on each onboarding step</CardDescription>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={funnelData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="step" />
              <YAxis label={{ value: 'Seconds', angle: -90, position: 'insideLeft' }} />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey="avgTime" stroke="#8884d8" name="Avg Time (seconds)" />
            </LineChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>
    </div>
  );
};

