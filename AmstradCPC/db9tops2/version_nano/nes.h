#ifndef NES_H
#define NES_H

/**
 * NES Controller Library for Arduino
 * Created by Daniel Fanara <fanardat16@gmail.com> 2016.
 * 
 * NES Documentation: http://www.mit.edu/~tarvizo/nes-controller.html
 * 
 * Button Mapping:
 * 0 = a
 * 1 = b
 * 2 = select
 * 3 = start
 * 4 = up
 * 5 = down
 * 6 = left
 * 7 = right
 *
 * Modifications version_nano :
 *  - constantes BTN_xxx deplacees dans le .h (utilisables dans le .ino)
 *  - broche data en INPUT_PULLUP (manette debranchee = aucun bouton appuye)
 *  - correction "pos = BTN_RIGHT" -> "pos == BTN_RIGHT"
 *  - pressed() retourne false par defaut
 *  (la lecture est faite en logiciel, aucune broche d'interruption requise)
 */

#define BTN_A 0
#define BTN_B 1
#define BTN_SELECT 2
#define BTN_START 3
#define BTN_UP 4
#define BTN_DOWN 5
#define BTN_LEFT 6
#define BTN_RIGHT 7

class Controller {
  public:
    Controller(int latch, int pulse, int data);
    void latch(); 
    bool pressed(int button);
    bool isLatched();
  private:
    void readState(int state);
    int _latch;
    int _pulse;
    int _data;
    bool _latched;
    bool _a;
    bool _b;
    bool _start;
    bool _select;
    bool _up;
    bool _down;
    bool _left;
    bool _right;   
};

#endif
