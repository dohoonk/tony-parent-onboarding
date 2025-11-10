'use client';

import React, { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { CheckCircle2, AlertCircle, Loader2 } from 'lucide-react';

interface SaveProgressBannerProps {
  onSave: () => Promise<void>;
  autoSaveEnabled?: boolean;
  lastSaveTime?: Date | null;
}

export const SaveProgressBanner: React.FC<SaveProgressBannerProps> = ({
  onSave,
  autoSaveEnabled = true,
  lastSaveTime
}) => {
  const [isSaving, setIsSaving] = useState(false);
  const [saveStatus, setSaveStatus] = useState<'idle' | 'success' | 'error'>('idle');
  const [timeSinceLastSave, setTimeSinceLastSave] = useState<string>('');

  useEffect(() => {
    if (!lastSaveTime) return;

    const updateTimeSince = () => {
      const now = new Date();
      const diffMs = now.getTime() - lastSaveTime.getTime();
      const diffMins = Math.floor(diffMs / 60000);
      
      if (diffMins === 0) {
        setTimeSinceLastSave('just now');
      } else if (diffMins === 1) {
        setTimeSinceLastSave('1 minute ago');
      } else if (diffMins < 60) {
        setTimeSinceLastSave(`${diffMins} minutes ago`);
      } else {
        const diffHours = Math.floor(diffMins / 60);
        setTimeSinceLastSave(diffHours === 1 ? '1 hour ago' : `${diffHours} hours ago`);
      }
    };

    updateTimeSince();
    const interval = setInterval(updateTimeSince, 60000); // Update every minute

    return () => clearInterval(interval);
  }, [lastSaveTime]);

  const handleManualSave = async () => {
    setIsSaving(true);
    setSaveStatus('idle');
    
    try {
      await onSave();
      setSaveStatus('success');
      setTimeout(() => setSaveStatus('idle'), 3000);
    } catch (error) {
      setSaveStatus('error');
      console.error('Failed to save progress:', error);
    } finally {
      setIsSaving(false);
    }
  };

  if (autoSaveEnabled && saveStatus === 'idle') {
    return null; // Don't show banner if auto-save is working fine
  }

  return (
    <Card className="mb-4 border-primary/20 bg-primary/5">
      <CardContent className="flex items-center justify-between p-4">
        <div className="flex items-center gap-3">
          {saveStatus === 'success' && (
            <>
              <CheckCircle2 className="h-5 w-5 text-green-600" />
              <div>
                <p className="text-sm font-medium">Progress saved</p>
                {timeSinceLastSave && (
                  <p className="text-xs text-muted-foreground">Last saved {timeSinceLastSave}</p>
                )}
              </div>
            </>
          )}
          
          {saveStatus === 'error' && (
            <>
              <AlertCircle className="h-5 w-5 text-destructive" />
              <div>
                <p className="text-sm font-medium text-destructive">Failed to save progress</p>
                <p className="text-xs text-muted-foreground">Click to try again</p>
              </div>
            </>
          )}
          
          {saveStatus === 'idle' && !autoSaveEnabled && (
            <div>
              <p className="text-sm font-medium">Your progress is not saved</p>
              <p className="text-xs text-muted-foreground">
                Save now to continue later from where you left off
              </p>
            </div>
          )}
        </div>

        <Button
          onClick={handleManualSave}
          disabled={isSaving}
          variant={saveStatus === 'error' ? 'destructive' : 'default'}
          size="sm"
        >
          {isSaving && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
          {isSaving ? 'Saving...' : 'Save Progress'}
        </Button>
      </CardContent>
    </Card>
  );
};

