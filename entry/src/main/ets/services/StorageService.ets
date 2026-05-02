import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

export class StorageService {
  private static instance: StorageService;
  private pref?: preferences.Preferences;

  private constructor() {}

  public static getInstance(): StorageService {
    if (!StorageService.instance) {
      StorageService.instance = new StorageService();
    }
    return StorageService.instance;
  }

  async init(context: common.Context) {
    try {
      this.pref = await preferences.getPreferences(context, 'allergy_prefs');
    } catch (err) {
      console.error('Failed to get preferences:', JSON.stringify(err));
    }
  }

  async put(key: string, value: preferences.ValueType) {
    if (this.pref) {
      this.pref.putSync(key, value);
      await this.pref.flush();
    }
  }

  getSync(key: string, defaultValue: preferences.ValueType): preferences.ValueType {
    if (this.pref) {
      return this.pref.getSync(key, defaultValue);
    }
    return defaultValue;
  }
}
