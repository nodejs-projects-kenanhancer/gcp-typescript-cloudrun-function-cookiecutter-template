export interface CloudEventFunction<T = unknown> {
  (cloudEvent: T): any;
}

export interface CloudEventMessage {
  message_id: string;
  publish_time: string;
  data?: string;
  attributes?: Record<string, string>;
}
