#include "nes.h"
#include <Arduino.h>

Controller::Controller(int latch, int pulse, int data) {
  pinMode(latch, OUTPUT);
  pinMode(pulse, OUTPUT);
  pinMode(data, INPUT_PULLUP);   // manette absente -> HIGH -> aucun bouton

  digitalWrite(latch, LOW);
  digitalWrite(pulse, LOW);

  _latch = latch;
  _pulse = pulse;
  _data = data;
  _latched = false;

  _a = _b = _up = _down = _left = _right = _start = _select = false;
}

void Controller::latch() {
  digitalWrite(_latch, HIGH);
  delayMicroseconds(12);
  digitalWrite(_latch, LOW);
  
  _latched = true;
  
  _a = false;
  _b = false;
  _up = false;
  _down = false;
  _left = false;
  _right = false;
  _start = false;
  _select = false;
  
  for(int i = 0; i < 8; i++) {
    readState(i);
    digitalWrite(_pulse, HIGH);
    delayMicroseconds(6);
    digitalWrite(_pulse, LOW);
    delayMicroseconds(6);
  }
  
  _latched = false;
}

void Controller::readState(int pos) {
  if(digitalRead(_data) == LOW) {
    if(pos == BTN_A) {
      _a = true;
    }else if(pos == BTN_B) {
      _b = true;
    }else if(pos == BTN_SELECT) {
      _select = true;
    }else if(pos == BTN_START) {
      _start = true;
    }else if(pos == BTN_UP) {
      _up = true;
    }else if(pos == BTN_DOWN) {
      _down = true;
    }else if(pos == BTN_LEFT) {
      _left = true;
    }else if(pos == BTN_RIGHT) {
      _right = true;
    }
  }
}

bool Controller::isLatched() {
  return _latched;
}

bool Controller::pressed(int button) {
  if(button == BTN_A)
    return _a;
  if(button == BTN_B)
    return _b;
  if(button == BTN_SELECT)
    return _select;
  if(button == BTN_START)
    return _start;
  if(button == BTN_UP)
    return _up;
  if(button == BTN_DOWN)
    return _down;
  if(button == BTN_LEFT)
    return _left;
  if(button == BTN_RIGHT)
    return _right;
  return false;
}
