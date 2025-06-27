import { Injectable, Logger } from '@nestjs/common';
import { CloudEventMessage } from '../types';

@Injectable()
export class SayHelloService {
  private readonly logger = new Logger(SayHelloService.name);

  async handleMessage(cloudEventMessage: CloudEventMessage): Promise<void> {
    try {
      this.logger.log('Processing CloudEvent message...');

      // Extract message details
      const { message_id, publish_time, data, attributes } = cloudEventMessage;

      // Log message metadata
      this.logger.log(`Message ID: ${message_id}`);
      this.logger.log(`Publish Time: ${publish_time}`);

      // Log attributes if present
      if (attributes) {
        this.logger.log(`Attributes: ${JSON.stringify(attributes, null, 2)}`);
      }

      // Process the message data
      if (data) {
        await this.processMessageData(data, attributes);
      } else {
        this.logger.warn('Received message with no data');
      }

      this.logger.log('Message processed successfully');
    } catch (error) {
      this.logger.error(
        `Failed to handle message: ${error instanceof Error ? error.message : String(error)}`,
        error instanceof Error ? error.stack : undefined,
      );
      throw error; // Re-throw to let the caller handle it
    }
  }

  private async processMessageData(
    data: string,
    attributes?: Record<string, string>,
  ): Promise<void> {
    this.logger.debug(`Processing data: ${data}`);

    // Parse data if it's JSON
    let parsedData: any;
    try {
      parsedData = JSON.parse(data);
      this.logger.debug(`Parsed data: ${JSON.stringify(parsedData, null, 2)}`);
    } catch {
      // Data is not JSON, treat as plain string
      this.logger.debug('Data is plain text (not JSON)');
      parsedData = data;
    }

    // Example: Handle different message types based on attributes
    if (attributes?.type === 'greeting') {
      await this.handleGreeting(parsedData);
    } else if (attributes?.type === 'notification') {
      await this.handleNotification(parsedData);
    } else {
      // Default processing
      await this.handleDefaultMessage(parsedData, attributes);
    }
  }

  private async handleGreeting(data: any): Promise<void> {
    this.logger.log('Processing greeting message');

    if (typeof data === 'string' && data.toLowerCase().includes('hello')) {
      this.logger.log('Hello! Greeting received and acknowledged.');
    } else if (data?.message?.toLowerCase().includes('hello')) {
      this.logger.log(`Hello ${data.name || 'there'}! Greeting received.`);
    }
  }

  private async handleNotification(data: any): Promise<void> {
    this.logger.log('Processing notification message');
    // Add notification handling logic here
    // For example: send email, push notification, etc.
  }

  private async handleDefaultMessage(
    data: any,
    attributes?: Record<string, string>,
  ): Promise<void> {
    this.logger.log('Processing default message');

    // Add your custom message processing logic here
    // For example:
    // - Save to database
    // - Send to message queue
    // - Trigger webhooks
    // - Transform and forward the message

    // Example: Log specific attributes
    if (attributes?.priority === 'high') {
      this.logger.warn('High priority message received!');
    }
  }
}