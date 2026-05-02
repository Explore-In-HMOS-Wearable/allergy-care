import { StorageService } from '../services/StorageService';
import { common } from '@kit.AbilityKit';

@Observed
export class AllergyViewModel {
  public pollenLevel: string = 'Low';
  public medRemaining: number = 0;
  public medActive: boolean = false;
  public symptomLevel: number = 0;
  public breathingText: Resource = $r('app.string.ready_label');
  public isBreathing: boolean = false;
  public breathScale: number = 0.6;
  public pulseScale: number = 0.6;

  private medTimer?: number;
  private breathTimer?: number;
  private pulseTimer?: number;
  private breathStep: number = 0;

  async init(context: common.Context) {
    await StorageService.getInstance().init(context);
    this.pollenLevel = StorageService.getInstance().getSync('pollen_level', 'Low') as string;
    this.symptomLevel = StorageService.getInstance().getSync('symptom_level', 0) as number;
  }

  setPollenLevel(level: string) {
    this.pollenLevel = level;
    StorageService.getInstance().put('pollen_level', level);
  }

  setSymptomLevel(level: number) {
    this.symptomLevel = level;
    StorageService.getInstance().put('symptom_level', level);
  }

  startMedication() {
    this.medRemaining = 30 * 60;
    this.medActive = true;
    clearInterval(this.medTimer);

    this.medTimer = setInterval(() => {
      if (this.medRemaining > 0) {
        this.medRemaining--;
      } else {
        this.medActive = false;
        clearInterval(this.medTimer);
      }
    }, 1000);
  }

  stopMedication() {
    this.medActive = false;
    clearInterval(this.medTimer);
    this.medRemaining = 0;
  }

  startBreathing(onHaptic: (effect: string) => void) {
    if (this.isBreathing) { 
      return
    };

    this.isBreathing = true;
    this.breathingText = $r('app.string.inhale_label');
    this.breathScale = 1.0;
    this.breathStep = 0;

    clearInterval(this.breathTimer);
    clearInterval(this.pulseTimer);

    this.breathTimer = setInterval(() => {
      switch (this.breathStep % 3) {
        case 0:
          this.breathingText = $r('app.string.inhale_label');
          this.breathScale = 1.0;
          onHaptic('watch_soft_heavy');
          break;
        case 1:
          this.breathingText = $r('app.string.hold_label');
          this.breathScale = 1.0;
          break;
        case 2:
          this.breathingText = $r('app.string.exhale_label');
          this.breathScale = 0.6;
          onHaptic('watch_soft_light');
          break;
      }
      this.breathStep++;
    }, 4000);

    this.pulseTimer = setInterval(() => {
      this.pulseScale = 1.2;
      setTimeout(() => {
        this.pulseScale = this.breathScale;
      }, 300);
    }, 1500);
  }

  stopBreathing() {
    this.isBreathing = false;
    clearInterval(this.breathTimer);
    clearInterval(this.pulseTimer);
    this.breathingText = $r('app.string.ready_label');
    this.breathScale = 0.6;
    this.pulseScale = 0.6;
  }
}
