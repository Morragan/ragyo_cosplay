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
uint8_t color_index = 0;
uint8_t stagger = 30;
uint8_t brightness = 50;

BLEService ledService(SERVICE_UUID);
BLEBoolCharacteristic disconnectCharacteristic(CHAR_UUID_DISCONNECT, BLEWriteWithoutResponse | BLERead);
BLEShortCharacteristic modeCharacteristic(CHAR_UUID_MODE, BLEWriteWithoutResponse | BLERead);
BLEShortCharacteristic colorIndexCharacteristic(CHAR_UUID_HUE, BLEWriteWithoutResponse | BLERead);
BLEShortCharacteristic speedCharacteristic(CHAR_UUID_SPEED, BLEWriteWithoutResponse | BLERead);

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
  ledService.addCharacteristic(colorIndexCharacteristic);
  ledService.addCharacteristic(disconnectCharacteristic);
  ledService.addCharacteristic(modeCharacteristic);
  BLE.addService(ledService);

  colorIndexCharacteristic.writeValue(0);
  disconnectCharacteristic.writeValue(false);
  modeCharacteristic.writeValue(0);
  BLE.advertise();
}

void loop() {
  EVERY_N_MILLIS(30) {
    BLEDevice phone = BLE.central();
    if (phone.connected()) {
      switch (mode) {
        case RAINBOW:
          rainbow_cycle();
          break;
        case RAVE:
          rave_cycle();
          break;
        case CONTROLLED:
          controlled_cycle();
          break;
      }
    } else {
      fill_solid(leds, NUM_LEDS, CRGB::Blue);
    }
    FastLED.show();
  }

  EVERY_N_MILLIS(500) {
    BLEDevice phone = BLE.central();
    if (disconnectCharacteristic.value()) {
      phone.disconnect();
      BLE.advertise();
      disconnectCharacteristic.writeValue(false);
    }
  }

  EVERY_N_MILLIS(500) {
    mode = static_cast<MODE_STATE>(modeCharacteristic.value());
  }
}

void rainbow_cycle() {
  uint8_t total = 0;
  for (int i = 0; i < NUM_SEGS; i++) {
    fill_solid(leds + total, segments[i], ColorFromPalette(palette, color_index + i * stagger));
    total += segments[i];
  }

  EVERY_N_MILLIS(30) {
    color_index++;
  }
}

void controlled_cycle() {
  color_index = colorIndexCharacteristic.value();

  uint8_t total = 0;
  for (int i = 0; i < NUM_SEGS; i++) {
    fill_solid(leds + total, segments[i], ColorFromPalette(palette, color_index + i * stagger));
    total += segments[i];
  }
}

void rave_cycle() {
  uint8_t total = 0;
  fill_solid(leds, NUM_LEDS, ColorFromPalette(palette, color_index));

  EVERY_N_MILLIS(900) {
    color_index = random8();
  }
}
