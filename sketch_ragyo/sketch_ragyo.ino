#include <FastLED.h>
#include <ArduinoBLE.h>
#include "secrets.h"

#define NUM_LEDS 30
#define SEG1 8
#define SEG2 7
#define SEG3 6
#define SEG4 5
#define SEG5 4
#define NUM_SEGS 5
#define DATA_PIN 4

CRGB leds[NUM_LEDS];
uint8_t segments[] = { SEG1, SEG2, SEG3, SEG4, SEG5 };
uint8_t hue = 0;
unsigned short rainbowSpeed = 30;
unsigned short raveSpeed = 1000;
uint8_t stagger = 30;
uint8_t brightness = 50;

BLEService ledService(SERVICE_UUID);
BLEShortCharacteristic disconnectCharacteristic(CHAR_UUID_DISCONNECT, BLEWriteWithoutResponse | BLEWrite | BLERead);
BLEShortCharacteristic modeCharacteristic(CHAR_UUID_MODE, BLEWriteWithoutResponse | BLERead);
BLEShortCharacteristic brightnessCharacteristic(CHAR_UUID_BRIGHTNESS, BLEWriteWithoutResponse | BLERead);
BLEShortCharacteristic hueCharacteristic(CHAR_UUID_HUE, BLEWriteWithoutResponse | BLERead);
BLEUnsignedIntCharacteristic rainbowSpeedCharacteristic(CHAR_UUID_RAINBOW_SPEED, BLEWriteWithoutResponse | BLERead);
BLEUnsignedIntCharacteristic raveSpeedCharacteristic(CHAR_UUID_RAVE_SPEED, BLEWriteWithoutResponse | BLERead);

enum MODE_STATE {
  RAINBOW,
  RAVE,
  CONTROLLED,
};

MODE_STATE mode = RAINBOW;

DEFINE_GRADIENT_PALETTE(rainbow_palette){
  0, 255, 0, 0,      // Red
  32, 171, 0, 85,    // Violet
  64, 75, 0, 130,    // Indigo
  96, 0, 0, 255,     // Blue
  128, 0, 255, 0,    // Green
  160, 255, 255, 0,  // Yellow
  192, 255, 127, 0,  // Orange
  255, 255, 0, 0     // Red
};

CRGBPalette16 palette = rainbow_palette;

void setup() {
  // Serial.begin(9600);
  // while (!Serial)
  //   ;

  randomSeed(analogRead(0));

  FastLED.clear();
  FastLED.setBrightness(brightness);
  FastLED.addLeds<WS2812B, DATA_PIN, GRB>(leds, NUM_LEDS);

  if (!BLE.begin()) {
    fill_solid(leds, NUM_LEDS, CRGB::Red);
    while (1)
      ;
  }

  BLE.setLocalName("Kiryuino");
  BLE.setAdvertisedService(ledService);
  ledService.addCharacteristic(disconnectCharacteristic);
  ledService.addCharacteristic(modeCharacteristic);
  ledService.addCharacteristic(brightnessCharacteristic);
  ledService.addCharacteristic(hueCharacteristic);
  ledService.addCharacteristic(rainbowSpeedCharacteristic);
  ledService.addCharacteristic(raveSpeedCharacteristic);
  BLE.addService(ledService);

  disconnectCharacteristic.writeValue(0);
  modeCharacteristic.writeValue(0);
  brightnessCharacteristic.writeValue(brightness);
  hueCharacteristic.writeValue(hue);
  rainbowSpeedCharacteristic.writeValue(rainbowSpeed);
  raveSpeedCharacteristic.writeValue(raveSpeed);
  BLE.advertise();
}

// TODO: adjust min/max speed; maybe decouple from the main EVERY_N_MILLIS(40) somehow?
void loop() {
  EVERY_N_MILLIS(40) {
    BLEDevice phone = BLE.central();
    if (phone.connected()) {
      mode = static_cast<MODE_STATE>(modeCharacteristic.value());
      brightness = brightnessCharacteristic.value();
      FastLED.setBrightness(brightness);

      switch (mode) {
        case RAINBOW:
          rainbowCycle();
          break;
        case RAVE:
          raveCycle();
          break;
        case CONTROLLED:
          controlledCycle();
          break;
      }

      if (disconnectCharacteristic.written() && disconnectCharacteristic.value()) {
        disconnectCharacteristic.writeValue(0);
        phone.disconnect();
        BLE.advertise();
      }
    } else {
      fill_solid(leds, NUM_LEDS, CRGB::Blue);
    }
    FastLED.show();
  }
}

void rainbowCycle() {
  static unsigned long lastMillis = millis();
  uint16_t diff = millis() - lastMillis;

  uint8_t total = 0;
  for (int i = 0; i < NUM_SEGS; i++) {
    fill_solid(leds + total, segments[i], ColorFromPalette(palette, hue + i * stagger));
    total += segments[i];
  }

  rainbowSpeed = rainbowSpeedCharacteristic.value();

  if (diff > rainbowSpeed) {
    hue += 2;
    lastMillis = millis();
  }
}

void controlledCycle() {
  hue = hueCharacteristic.value();

  uint8_t total = 0;
  for (int i = 0; i < NUM_SEGS; i++) {
    fill_solid(leds + total, segments[i], ColorFromPalette(palette, hue + i * stagger));
    total += segments[i];
  }
}

void raveCycle() {
  static unsigned long lastMillis = millis();
  uint16_t diff = millis() - lastMillis;

  uint8_t total = 0;
  fill_solid(leds, NUM_LEDS, ColorFromPalette(palette, hue));

  raveSpeed = raveSpeedCharacteristic.value();

  if (diff > raveSpeed) {
    uint8_t random = random8();
    while (abs(hue - random) < 50) random = random8();
    hue = random8();
    lastMillis = millis();
  }
}
