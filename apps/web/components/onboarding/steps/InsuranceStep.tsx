'use client';

import React, { useState, useRef } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Upload, X, CheckCircle2, AlertCircle, Loader2 } from 'lucide-react';
import { cn } from '@/lib/utils';
import { InsuranceExtractionResults } from '../InsuranceExtractionResults';
import { ManualInsuranceForm } from '../ManualInsuranceForm';

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

  const handleUpload = async (side: 'front' | 'back') => {
    const image = side === 'front' ? frontImage : backImage;
    if (!image) return;

    // TODO: Get presigned URL and upload to S3
    // For now, simulate upload
    if (side === 'front') {
      setFrontImage((prev) => prev ? { ...prev, uploading: true } : null);
    } else {
      setBackImage((prev) => prev ? { ...prev, uploading: true } : null);
    }

    try {
      // Simulate upload
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      const mockUrl = `https://s3.example.com/insurance-cards/${side}-${Date.now()}.jpg`;
      
      if (side === 'front') {
        setFrontImage((prev) => prev ? { ...prev, url: mockUrl, uploading: false } : null);
      } else {
        setBackImage((prev) => prev ? { ...prev, url: mockUrl, uploading: false } : null);
      }
    } catch (err) {
      if (side === 'front') {
        setFrontImage((prev) => prev ? { ...prev, uploading: false, error: 'Upload failed' } : null);
      } else {
        setBackImage((prev) => prev ? { ...prev, uploading: false, error: 'Upload failed' } : null);
      }
    }
  };

  const handleExtract = async () => {
    if (!frontImage?.url) {
      setError('Please upload at least the front of your insurance card');
      return;
    }

    setIsProcessing(true);
    setError(null);

    try {
      // TODO: Call GraphQL mutation to extract insurance data
      await new Promise((resolve) => setTimeout(resolve, 2000));
      
      // Mock extracted data
      setExtractedData({
        payer_name: 'Blue Cross Blue Shield',
        member_id: 'ABC123456789',
        group_number: 'GRP001',
        confidence: {
          payer_name: 'high',
          member_id: 'medium',
          group_number: 'low'
        }
      });
    } catch (err) {
      setError('Failed to extract insurance information. Please enter manually.');
      console.error(err);
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="rounded-md border bg-muted/50 p-4">
        <h3 className="font-semibold">Insurance Information</h3>
        <p className="mt-1 text-sm text-muted-foreground">
          Upload photos of your insurance card (front and back) and we'll extract the information for you.
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
                    Uploaded
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
            {frontImage && !frontImage.url && (
              <Button
                type="button"
                onClick={() => handleUpload('front')}
                disabled={frontImage.uploading}
                className="w-full"
                size="sm"
              >
                {frontImage.uploading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Uploading...
                  </>
                ) : (
                  'Upload to Server'
                )}
              </Button>
            )}
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
                    Uploaded
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
            {backImage && !backImage.url && (
              <Button
                type="button"
                onClick={() => handleUpload('back')}
                disabled={backImage.uploading}
                className="w-full"
                size="sm"
              >
                {backImage.uploading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Uploading...
                  </>
                ) : (
                  'Upload to Server'
                )}
              </Button>
            )}
          </CardContent>
        </Card>
      </div>

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

      {/* Extraction Results */}
      {extractedData && !showManualForm && (
        <InsuranceExtractionResults
          extractedData={extractedData}
          onConfirm={(data) => {
            setConfirmedData(data);
            setShowManualForm(false);
          }}
          onEdit={() => setShowManualForm(true)}
        />
      )}

      {/* Manual Entry Form */}
      {showManualForm && (
        <ManualInsuranceForm
          initialData={extractedData ? Object.fromEntries(
            Object.entries(extractedData).map(([key, field]: [string, any]) => [
              key,
              field?.value || ''
            ])
          ) : {}}
          onSubmit={(data) => {
            setConfirmedData(data);
            setShowManualForm(false);
          }}
          onCancel={() => {
            if (extractedData) {
              setShowManualForm(false);
            } else {
              setFrontImage(null);
              setBackImage(null);
            }
          }}
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
        <Button
          onClick={onNext}
          disabled={!confirmedData}
          className="w-full sm:w-auto"
        >
          Continue
        </Button>
      </div>
    </div>
  );
};

