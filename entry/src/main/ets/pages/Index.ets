@Entry
@Component
struct AllergyHealthPage {



  // Pollen
  @State pollenLevel: string = 'Low';

  // Medication
  @State medRemaining: number = 0;
  @State medActive: boolean = false;
  private medTimer?: number;

  // Symptom
  @State symptomLevel: number = 0;

  // Breathing
  @State breathingText: string = 'Ready';
  @State isBreathing: boolean = false;
  @State breathScale: number = 0.6;
  @State pulseScale: number = 0.6;

  private breathTimer?: number;
  private pulseTimer?: number;
  private breathStep: number = 0;



  build() {
    Scroll(){
      Column({ space: 12 }) {


        Text('Allergy Care')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#601f9e')

        //Pollen
        Text('Pollen')
          .fontSize(14)
          .fontColor('#f7e194')

        Row({ space: 6 }) {
          this.pollenButton('Low')
          this.pollenButton('Mid')
          this.pollenButton('High')
        }

        if (this.pollenLevel === 'High') {
          Text('Avoid outdoor activities')
            .fontSize(12)
            .fontColor(Color.Red)
        }
        Divider()
        //Medication
        Text('Medication Reminder')
          .fontColor('#f7e194')
          .fontSize(14)
          .margin({ top: 6 })

        if (!this.medActive) {
          Button('Set to 30m')
            .borderRadius(18)
            .backgroundColor(Color.Green)
            .width(100)
            .height(36)
            .onClick(() => this.startMedication())
        } else {
          Text(`${Math.floor(this.medRemaining / 60)}m ${this.medRemaining % 60}s`)
            .fontSize(16)
        }

        Divider()

        //Symptoms
        Text('Symptoms')
          .fontColor('#f7e194')
          .fontSize(14)
          .margin({ top: 6 })


        Slider({
          value: this.symptomLevel,
          min: 0,
          max: 10,
          step: 1
        })
          .width('70%')
          .onChange(v => this.symptomLevel = v)

        Text(`Level ${this.symptomLevel}`)
          .fontSize(12)
          .fontColor(this.symptomColor())

        Divider()

        //Breathing
        Text('Breathing')
          .fontWeight(FontWeight.Medium)
          .opacity(0.85)
          .fontColor('#f7e194')
          .fontSize(14)
          .margin({ top: 6 })

        this.BreathingCircle()

        Text(this.breathingText)
          .fontSize(16)

        Button('Start')
          .width(70)
          .height(32)
          .onClick(() => this.startBreathing())

        Button('Stop')
          .width(70)
          .height(32)
          .backgroundColor('#B71C1C')
          .onClick(() => this.stopBreathing())

      }
      .width('85%')
      .padding({ top: 20, bottom: 7, left: 33 })
      .alignItems(HorizontalAlign.Center)
      .borderRadius(16)
    }
  }
  //Builders

  @Builder
  pollenButton(level: string) {
    Button(level.charAt(0))
      .width(44)
      .height(32)
      .borderRadius(14)
      .fontSize(12)
      .backgroundColor(this.pollenLevel === level ? '#4CAF50' : '#333')
      .onClick(() => this.pollenLevel = level)
  }

  @Builder
  BreathingCircle() {
    Stack() {

      // Pulse ring
      Circle()
        .width(110)
        .height(110)
        .stroke(Color.Blue)
        .strokeWidth(3)
        .opacity(0.4)
        .scale({ x: this.pulseScale, y: this.pulseScale })
        .animation({
          duration: 1500,
          curve: Curve.EaseOut
        })

      // Main breathing circle
      Circle()
        .width(120)
        .height(120)
        .fill(Color.Green)
        .scale({ x: this.breathScale, y: this.breathScale })
        .animation({
          duration: 4000,
          curve: Curve.EaseInOut
        })
    }

  }

  //Functions

  startMedication() {
    this.medRemaining = 30 * 60;
    this.medActive = true;
    clearInterval(this.medTimer);

    this.medTimer = setInterval(() => {
      if (this.medRemaining > 0) {
        this.medRemaining--;
      } else {
        clearInterval(this.medTimer);
        this.medActive = false;
        console.info('Take your medication');
      }
    }, 1000);
  }

  symptomColor(): Color {
    if (this.symptomLevel <= 3) {return Color.Green}
    if (this.symptomLevel <= 6) {return Color.Orange}
    return Color.Red;
  }

  startBreathing() {
    if (this.isBreathing){
      return;
    }

    this.isBreathing = true;
    this.breathingText = 'Inhale'
    this.breathScale = 1.0;

    clearInterval(this.breathTimer);
    clearInterval(this.pulseTimer);

    this.breathStep = 0;

    //Breathing cycle
    this.breathTimer = setInterval(() => {
      switch (this.breathStep % 3) {
        case 0:
          this.breathingText = 'Inhale';
          this.breathScale = 1.0;
          break;
        case 1:
          this.breathingText = 'Hold';
          this.breathScale = 1.0;
          break;
        case 2:
          this.breathingText = 'Exhale';
          this.breathScale = 0.6;
          break;
      }
      this.breathStep++;
    }, 4000);

    //Pulse effect
    this.pulseTimer = setInterval(() => {
      this.pulseScale = 1.2;
      setTimeout(() => {
        this.pulseScale = this.breathScale;
      }, 300);
    }, 1500);
  }

  stopBreathing(){
    this.isBreathing = false;

    clearInterval(this.breathTimer);
    clearInterval(this.pulseTimer);

    this.breathingText = 'Ready';
    this.breathScale = 0.6;
    this.pulseScale = 0.6
  }
}