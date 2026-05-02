import { vibrator } from '@kit.SensorServiceKit';
import { AllergyViewModel } from '../viewmodel/AllergyViewModel';
import { NotificationService } from '../services/NotificationService';
import { ReminderService } from '../services/ReminderService';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct AllergyHealthPage {
  @State viewModel: AllergyViewModel = new AllergyViewModel();

  aboutToAppear() {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.viewModel.init(context);
  }

  aboutToDisappear() {
    this.viewModel.stopBreathing();
    this.viewModel.stopMedication();
  }

  build() {
    List({ space: 12 }) {
      ListItem() {
        Column({ space: 8 }) {
          Text($r('app.string.app_title'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.title_color'))
            .margin({ top: 20 })
        }
        .width('100%')
      }

      // Pollen Section
      ListItem() {
        PollenSection({ viewModel: this.viewModel })
      }

      ListItem() { Divider().strokeWidth(1).color('#333') }

      // Medication Section
      ListItem() {
        MedicationSection({ viewModel: this.viewModel })
      }

      ListItem() { Divider().strokeWidth(1).color('#333') }

      // Symptoms Section
      ListItem() {
        SymptomSection({ viewModel: this.viewModel })
      }

      ListItem() { Divider().strokeWidth(1).color('#333') }

      // Breathing Section
      ListItem() {
        BreathingSection({
          viewModel: this.viewModel,
          triggerHaptic: (effect: string): void => this.triggerHaptic(effect)
        })
      }
    }
    .width('100%')
    .height('100%')
    .alignListItem(ListItemAlign.Center)
  }

  triggerHaptic(effect: string) {
    try {
      vibrator.startVibration({
        type: 'preset',
        effectId: effect,
        count: 1
      }, {
        usage: 'alarm'
      }, (error) => {
        if (error) {
          console.error(`Vibration failed. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        console.info('Vibration succeeded.');
      });
    } catch (err) {
      console.error(`An unexpected error occurred. Code: ${err.code}, message: ${err.message}`);
    }
  }
}

@Component
struct PollenSection {
  @ObjectLink viewModel: AllergyViewModel;

  build() {
    Column({ space: 8 }) {
      Text($r('app.string.pollen_label'))
        .fontSize(16)
        .fontColor($r('app.color.section_title_color'))

      Row({ space: 10 }) {
        this.pollenButton('Low', $r('app.string.pollen_low'))
        this.pollenButton('Mid', $r('app.string.pollen_mid'))
        this.pollenButton('High', $r('app.string.pollen_high'))
      }

      if (this.viewModel.pollenLevel === 'High') {
        Text($r('app.string.pollen_warning_high'))
          .fontSize(14)
          .fontColor($r('app.color.error_color'))
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
  }

  @Builder
  pollenButton(level: string, label: Resource) {
    Button(label)
      .width(50)
      .height(40)
      .borderRadius(16)
      .fontSize(8)
      .backgroundColor(this.viewModel.pollenLevel === level ? $r('app.color.active_pollen_color') : $r('app.color.inactive_pollen_color'))
      .onClick(() => {
        this.viewModel.setPollenLevel(level);
        if (level === 'High') {
          NotificationService.getInstance().publishPollenAlert();
        } else {
          NotificationService.getInstance().cancelAlert();
        }
      })
  }
}

@Component
struct MedicationSection {
  @ObjectLink viewModel: AllergyViewModel;

  build() {
    Column({ space: 8 }) {
      Text($r('app.string.medication_reminder_label'))
        .fontColor($r('app.color.section_title_color'))
        .fontSize(16)

      if (!this.viewModel.medActive) {
        Button($r('app.string.medication_set_timer'))
          .borderRadius(20)
          .backgroundColor($r('app.color.success_color'))
          .width(120)
          .height(40)
          .onClick(() => {
            this.viewModel.startMedication();
            ReminderService.getInstance().addMedicationReminder(30 * 60);
          })
      } else {
        Column({ space: 4 }) {
          Text(`${Math.floor(this.viewModel.medRemaining / 60)}m ${this.viewModel.medRemaining % 60}s`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)

          Button('Reset')
            .fontSize(12)
            .height(24)
            .onClick(() => {
              this.viewModel.stopMedication();
              ReminderService.getInstance().cancelReminder();
            })
        }
      }
    }
    .width('100%')
  }
}

@Component
struct SymptomSection {
  @ObjectLink viewModel: AllergyViewModel;

  build() {
    Column({ space: 8 }) {
      Text($r('app.string.symptoms_label'))
        .fontColor($r('app.color.section_title_color'))
        .fontSize(16)

      Slider({
        value: this.viewModel.symptomLevel,
        min: 0,
        max: 10,
        step: 1
      })
        .width('80%')
        .onChange(v => this.viewModel.setSymptomLevel(v))

      Text($r('app.string.level_label', this.viewModel.symptomLevel))
        .fontSize(14)
        .fontColor(this.symptomColor())
    }
    .width('100%')
  }

  symptomColor(): Resource {
    if (this.viewModel.symptomLevel <= 3) { return $r('app.color.success_color') }
    if (this.viewModel.symptomLevel <= 6) { return $r('app.color.warning_color') }
    return $r('app.color.error_color');
  }
}

@Component
struct BreathingSection {
  @ObjectLink viewModel: AllergyViewModel;
  triggerHaptic: (effect: string) => void = () => {};

  build() {
    Column({ space: 12 }) {
      Text($r('app.string.breathing_label'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.section_title_color'))
        .fontSize(16)

      this.BreathingCircle()

      Text(this.viewModel.breathingText)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)

      Row({ space: 12 }) {
        Button($r('app.string.start_label'))
          .width(80)
          .height(36)
          .onClick(() => this.viewModel.startBreathing(this.triggerHaptic))

        Button($r('app.string.stop_label'))
          .width(80)
          .height(36)
          .backgroundColor($r('app.color.stop_button_color'))
          .onClick(() => this.viewModel.stopBreathing())
      }
      .margin({ bottom: 40 })
    }
    .width('100%')
  }

  @Builder
  BreathingCircle() {
    Stack() {
      Circle()
        .width(110)
        .height(110)
        .stroke($r('app.color.pulse_color'))
        .strokeWidth(3)
        .opacity(0.4)
        .scale({ x: this.viewModel.pulseScale, y: this.viewModel.pulseScale })
        .animation({
          duration: 1500,
          curve: Curve.EaseOut
        })

      Circle()
        .width(120)
        .height(120)
        .fill($r('app.color.success_color'))
        .scale({ x: this.viewModel.breathScale, y: this.viewModel.breathScale })
        .animation({
          duration: 4000,
          curve: Curve.EaseInOut
        })
    }
  }
}
