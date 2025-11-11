'use client';

import React, { useState, useRef } from 'react';
import { useMutation } from '@apollo/client';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Upload, X, CheckCircle2, AlertCircle, Loader2 } from 'lucide-react';
import { cn } from '@/lib/utils';
import { ManualInsuranceForm } from '../ManualInsuranceForm';
import { UPLOAD_INSURANCE_CARD } from '@/lib/graphql/mutations';

interface InsuranceStepProps {
  onNext: () => void;
  onPrev: () => void;
  sessionId?: string;
}

interface UploadedImage {
  file: File;
  preview: string;
  url?: string;
  uploading?: boolean;
  error?: string;
}

export const InsuranceStep: React.FC<InsuranceStepProps> = ({
  onNext,
  onPrev,
  sessionId
}) => {
  const [frontImage, setFrontImage] = useState<UploadedImage | null>(null);
  const [backImage, setBackImage] = useState<UploadedImage | null>(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const [extractedData, setExtractedData] = useState<any>(null);
  const [showManualForm, setShowManualForm] = useState(false);
  const [confirmedData, setConfirmedData] = useState<Record<string, string> | null>(null);
  const [error, setError] = useState<string | null>(null);
  
  const frontInputRef = useRef<HTMLInputElement>(null);
  const backInputRef = useRef<HTMLInputElement>(null);
  const [uploadInsuranceCard] = useMutation(UPLOAD_INSURANCE_CARD);

  const handleImageSelect = (
    e: React.ChangeEvent<HTMLInputElement>,
    side: 'front' | 'back'
  ) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith('image/')) {
      setError('Please upload an image file');
      return;
    }

    // Validate file size (max 10MB)
    if (file.size > 10 * 1024 * 1024) {
      setError('Image must be less than 10MB');
      return;
    }

    const reader = new FileReader();
    reader.onload = (event) => {
      const preview = event.target?.result as string;
      const uploaded: UploadedImage = {
        file,
        preview,
        url: preview,
        uploading: false
      };

      if (side === 'front') {
        setFrontImage(uploaded);
      } else {
        setBackImage(uploaded);
      }
      setError(null);
    };
    reader.readAsDataURL(file);
  };

  const handleRemoveImage = (side: 'front' | 'back') => {
    if (side === 'front') {
      setFrontImage(null);
      if (frontInputRef.current) frontInputRef.current.value = '';
    } else {
      setBackImage(null);
      if (backInputRef.current) backInputRef.current.value = '';
    }
  };

  const handleExtract = async () => {
    if (!frontImage) {
      setError('Please upload at least the front of your insurance card');
      return;
    }

    if (!sessionId) {
      setError('Session ID is required');
      return;
    }

    setIsProcessing(true);
    setError(null);

    try {
      // Use the base64 data URL (preview) instead of the fake S3 URL
      // This allows OCR to work immediately without needing to upload to S3 first
      const { data } = await uploadInsuranceCard({
        variables: {
          input: {
            sessionId: sessionId,
            frontImageUrl: frontImage.preview, // Use base64 data URL
            backImageUrl: backImage?.preview || null // Use base64 data URL
          }
        }
      });

      if (data?.uploadInsuranceCard?.errors?.length > 0) {
        setError(data.uploadInsuranceCard.errors.join(', '));
        return;
      }

      if (!data?.uploadInsuranceCard?.insuranceCard) {
        setError('Failed to upload insurance card. Please try again or enter manually.');
        return;
      }

      const extractedDataFromAPI = data.uploadInsuranceCard.insuranceCard.extractedData;
      
      if (extractedDataFromAPI && Object.keys(extractedDataFromAPI).length > 0) {
        // Data is already in the correct format: { payer_name: { value: "...", confidence: "high" }, ... }
        setExtractedData(extractedDataFromAPI);
        setConfirmedData(null);
        setShowManualForm(true);
      } else {
        setError('No data extracted from the insurance card. Please try again or enter manually.');
      }
    } catch (err: any) {
      console.error('OCR extraction error:', err);
      setError(err.message || 'Failed to extract insurance information. Please enter manually.');
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="rounded-md border bg-muted/50 p-4">
        <h3 className="font-semibold">Insurance Information</h3>
        <p className="mt-1 text-sm text-muted-foreground">
          Upload photos of your insurance card (front and back) and we&apos;ll extract the information for you.
        </p>
      </div>

      {/* Image Upload Section */}
      <div className="grid gap-4 sm:grid-cols-2">
        {/* Front Image */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Front of Card</CardTitle>
            <CardDescription>Upload the front of your insurance card</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {frontImage ? (
              <div className="relative">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={frontImage.preview}
                  alt="Insurance card front"
                  className="w-full rounded-md border"
                />
                <Button
                  type="button"
                  variant="destructive"
                  size="icon"
                  className="absolute top-2 right-2"
                  onClick={() => handleRemoveImage('front')}
                  aria-label="Remove front image"
                >
                  <X className="h-4 w-4" />
                </Button>
                {frontImage.uploading && (
                  <div className="absolute inset-0 flex items-center justify-center bg-background/80 rounded-md">
                    <Loader2 className="h-6 w-6 animate-spin" />
                  </div>
                )}
                {frontImage.url && (
                  <div className="mt-2 flex items-center gap-2 text-sm text-green-600">
                    <CheckCircle2 className="h-4 w-4" />
                    Ready for extraction
                  </div>
                )}
                {frontImage.error && (
                  <div className="mt-2 flex items-center gap-2 text-sm text-destructive">
                    <AlertCircle className="h-4 w-4" />
                    {frontImage.error}
                  </div>
                )}
              </div>
            ) : (
              <div
                className={cn(
                  'flex flex-col items-center justify-center border-2 border-dashed rounded-lg p-8 cursor-pointer transition-colors',
                  'hover:bg-muted/50'
                )}
                onClick={() => frontInputRef.current?.click()}
              >
                <Upload className="h-10 w-10 text-muted-foreground mb-4" />
                <p className="text-sm font-medium">Click to upload</p>
                <p className="text-xs text-muted-foreground mt-1">PNG, JPG up to 10MB</p>
              </div>
            )}
            <input
              ref={frontInputRef}
              type="file"
              accept="image/*"
              onChange={(e) => handleImageSelect(e, 'front')}
              className="hidden"
              aria-label="Upload front of insurance card"
            />
          </CardContent>
        </Card>

        {/* Back Image */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Back of Card (Optional)</CardTitle>
            <CardDescription>Upload the back if it contains important information</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {backImage ? (
              <div className="relative">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={backImage.preview}
                  alt="Insurance card back"
                  className="w-full rounded-md border"
                />
                <Button
                  type="button"
                  variant="destructive"
                  size="icon"
                  className="absolute top-2 right-2"
                  onClick={() => handleRemoveImage('back')}
                  aria-label="Remove back image"
                >
                  <X className="h-4 w-4" />
                </Button>
                {backImage.uploading && (
                  <div className="absolute inset-0 flex items-center justify-center bg-background/80 rounded-md">
                    <Loader2 className="h-6 w-6 animate-spin" />
                  </div>
                )}
                {backImage.url && (
                  <div className="mt-2 flex items-center gap-2 text-sm text-green-600">
                    <CheckCircle2 className="h-4 w-4" />
                    Ready for extraction
                  </div>
                )}
              </div>
            ) : (
              <div
                className={cn(
                  'flex flex-col items-center justify-center border-2 border-dashed rounded-lg p-8 cursor-pointer transition-colors',
                  'hover:bg-muted/50'
                )}
                onClick={() => backInputRef.current?.click()}
              >
                <Upload className="h-10 w-10 text-muted-foreground mb-4" />
                <p className="text-sm font-medium">Click to upload</p>
                <p className="text-xs text-muted-foreground mt-1">PNG, JPG up to 10MB</p>
              </div>
            )}
            <input
              ref={backInputRef}
              type="file"
              accept="image/*"
              onChange={(e) => handleImageSelect(e, 'back')}
              className="hidden"
              aria-label="Upload back of insurance card"
            />
          </CardContent>
        </Card>
      </div>

      {!showManualForm && (
        <div className="flex justify-end">
          <Button variant="link" type="button" onClick={() => {
            setShowManualForm(true);
            setExtractedData(null);
            setConfirmedData(null);
          }}>
            Enter information manually instead
          </Button>
        </div>
      )}

      {/* Extract Button */}
      {frontImage?.url && !extractedData && !showManualForm && (
        <div className="flex justify-center">
          <Button
            type="button"
            onClick={handleExtract}
            disabled={isProcessing}
            size="lg"
          >
            {isProcessing ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Extracting Information...
              </>
            ) : (
              'Extract Insurance Information'
            )}
          </Button>
        </div>
      )}

      {/* Manual Entry Form */}
      {showManualForm && (
        <ManualInsuranceForm
          initialData={(() => {
            if (confirmedData) {
              return confirmedData;
            }
            if (extractedData) {
              return Object.fromEntries(
                Object.entries(extractedData).map(([key, field]: [string, any]) => [
                  key,
                  field?.value || ''
                ])
              );
            }
            return {};
          })()}
          confidenceMap={extractedData ? Object.fromEntries(
            Object.entries(extractedData).map(([key, field]: [string, any]) => [
              key,
              field?.confidence || ''
            ])
          ) : undefined}
          onSubmit={(data) => {
            setConfirmedData(data);
            onNext();
          }}
          onCancel={
            showManualForm && !extractedData
              ? () => {
                  setShowManualForm(false);
                  setConfirmedData(null);
                }
              : extractedData
              ? () => setShowManualForm(false)
              : undefined
          }
        />
      )}

      {error && (
        <div className="rounded-md bg-destructive/10 p-3 text-sm text-destructive" role="alert">
          {error}
        </div>
      )}

      <div className="flex flex-col-reverse gap-3 sm:flex-row sm:justify-between">
        <Button type="button" variant="outline" onClick={onPrev} className="w-full sm:w-auto">
          Back
        </Button>
      </div>
    </div>
  );
};

