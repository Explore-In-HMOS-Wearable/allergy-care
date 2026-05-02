import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class ReminderService {
  private static instance: ReminderService;
  private reminderId: number = -1;

  private constructor() {}

  public static getInstance(): ReminderService {
    if (!ReminderService.instance) {
      ReminderService.instance = new ReminderService();
    }
    return ReminderService.instance;
  }

  public async addMedicationReminder(seconds: number) {
    let timer: reminderAgentManager.ReminderRequestTimer = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
      triggerTimeInSeconds: seconds,
      title: 'Medication Time',
      content: 'Time to take your allergy medication.',
      expiredContent: 'Medication reminder expired',
      notificationId: 100,
      slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION
    };

    try {
      this.reminderId = await reminderAgentManager.publishReminder(timer);
      console.info(`Reminder published, ID: ${this.reminderId}`);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`Failed to publish reminder: ${error.code}, ${error.message}`);
    }
  }

  public async cancelReminder() {
    if (this.reminderId !== -1) {
      try {
        await reminderAgentManager.cancelReminder(this.reminderId);
        this.reminderId = -1;
      } catch (err) {
        let error = err as BusinessError;
        console.error(`Failed to cancel reminder: ${error.code}, ${error.message}`);
      }
    }
  }
}
