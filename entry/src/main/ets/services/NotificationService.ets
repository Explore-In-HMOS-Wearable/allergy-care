import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class NotificationService {
  private static instance: NotificationService;

  private constructor() {}

  public static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  public publishPollenAlert() {
    let request: notificationManager.NotificationRequest = {
      id: 1,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: 'High Pollen Alert',
          text: 'Pollen levels are high today. Please take necessary precautions.',
          additionalText: 'Allergy Care'
        }
      }
    };

    notificationManager.publish(request).then(() => {
      console.info('Pollen alert published');
    }).catch((err: BusinessError) => {
      console.error(`Failed to publish alert: ${err.code}, ${err.message}`);
    });
  }

  public cancelAlert() {
    notificationManager.cancel(1);
  }
}
