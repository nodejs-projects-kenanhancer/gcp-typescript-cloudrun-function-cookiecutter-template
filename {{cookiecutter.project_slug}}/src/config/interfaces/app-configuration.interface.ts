import { BasicSettings } from './basic-settings.interface';
import { ServerSettings } from './server-settings.interface';

export interface AppConfiguration {
  serverSettings: ServerSettings;
  basicSettings: BasicSettings;
}
