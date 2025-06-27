import { Logger } from '@nestjs/common';
import { getNestApp } from './app.config';
import { {{ cookiecutter.function_name_pascal }}Service } from './{{ cookiecutter.function_name_kebab }}';
import { CloudEventFunction, CloudEventMessage } from './types';

export const cloudRunFunctionLogger = new Logger('CloudRunFunction');

export const main: CloudEventFunction<CloudEventMessage> = async (
  cloudEventMessage: CloudEventMessage,
) => {
  try {
    const app = await getNestApp();
    const {{ cookiecutter.function_name_camel }}Service = app.get({{ cookiecutter.function_name_pascal }}Service);
    cloudRunFunctionLogger.log(
      'RAW EVENT ↓\n' + JSON.stringify(cloudEventMessage, null, 2),
    );
    await {{ cookiecutter.function_name_camel }}Service.handleMessage(cloudEventMessage);
  } catch (error: unknown) {
    // Type check the error before accessing properties
    if (error instanceof Error) {
      cloudRunFunctionLogger.error(
        `Error processing Cloud Run message: ${error.message}`,
        error.stack,
      );
    } else {
      // Handle case where error might not be an Error object
      cloudRunFunctionLogger.error(`Error processing Cloud Run message: ${String(error)}`);
    }
    throw error; // Re-throw to signal failure to Cloud Functions
  }
};
