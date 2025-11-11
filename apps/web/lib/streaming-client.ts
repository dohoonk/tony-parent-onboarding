/**
 * Client for streaming AI responses via Server-Sent Events
 */

export interface StreamChunk {
  type: 'chunk' | 'complete' | 'error';
  content?: string;
  message_id?: string;
  message?: string;
}

export class StreamingClient {
  private eventSource: EventSource | null = null;
  private onChunk: (chunk: string) => void;
  private onComplete: (messageId: string) => void;
  private onError: (error: string) => void;

  constructor(
    onChunk: (chunk: string) => void,
    onComplete: (messageId: string) => void,
    onError: (error: string) => void
  ) {
    this.onChunk = onChunk;
    this.onComplete = onComplete;
    this.onError = onError;
  }

  /**
   * Start streaming from the API endpoint
   * @param sessionId Onboarding session ID
   * @param messageId User message ID that triggered the stream
   * @param token JWT authentication token
   */
  start(sessionId: string, messageId: string, token: string): void {
    if (this.eventSource) {
      this.stop();
    }

    const url = `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000'}/api/stream/intake/${sessionId}/${messageId}`;
    
    // Create EventSource with authentication header
    // Note: EventSource doesn't support custom headers, so we'll use query param or cookie
    // For production, use cookies or a different approach
    this.eventSource = new EventSource(`${url}?token=${encodeURIComponent(token)}`);

    this.eventSource.onmessage = (event) => {
      try {
        const data: StreamChunk = JSON.parse(event.data);
        
        switch (data.type) {
          case 'chunk':
            if (data.content) {
              this.onChunk(data.content);
            }
            break;
          case 'complete':
            if (data.message_id) {
              this.onComplete(data.message_id);
            }
            this.stop();
            break;
          case 'error':
            this.onError(data.message || 'Streaming error occurred');
            this.stop();
            break;
        }
      } catch (error) {
        console.error('Failed to parse stream data:', error);
        this.onError('Failed to parse stream data');
      }
    };

    this.eventSource.onerror = (error) => {
      console.error('EventSource error:', error);
      
      // Check the ready state to determine the error type
      if (this.eventSource?.readyState === EventSource.CLOSED) {
        // Connection was closed - could be auth error, server error, or network issue
        this.onError('Unable to connect to the server. Please check your connection and try again.');
      } else if (this.eventSource?.readyState === EventSource.CONNECTING) {
        // Still connecting - wait a bit before showing error
        setTimeout(() => {
          if (this.eventSource?.readyState !== EventSource.OPEN) {
            this.onError('Connection timeout. The server may be unavailable.');
            this.stop();
          }
        }, 5000);
      } else {
        this.onError('Connection error. Please try again.');
      }
      this.stop();
    };
  }

  /**
   * Stop streaming and close the connection
   */
  stop(): void {
    if (this.eventSource) {
      this.eventSource.close();
      this.eventSource = null;
    }
  }

  /**
   * Check if currently streaming
   */
  isStreaming(): boolean {
    return this.eventSource !== null && this.eventSource.readyState === EventSource.OPEN;
  }
}

