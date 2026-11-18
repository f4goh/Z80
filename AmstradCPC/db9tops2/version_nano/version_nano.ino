/*
 * version_nano.ino
 * Passerelle manettes DB9 / NES -> clavier PS/2 sur Arduino Nano (ATmega328P)
 *
 * - Joueur 1 : manette DB9 n°1 OU manette NES (les deux peuvent etre
 *   branchees en meme temps, leurs appuis sont combines).
 * - Joueur 2 : manette DB9 n°2.
 * - Touches PS/2 au format CPCESP :
 *     Joueur 1 : fleches Haut/Bas/Gauche/Droite, Feu1 = ALT droit (AltGr), Feu2 = ALT gauche
 *                NES : A = Feu1, B = Feu2, START = Entree, SELECT = F1 (menu emulateur)
 *     Joueur 2 : 6 / 5 / R / T,                  Feu1 = G,                Feu2 = F
 * - Test serie conserve : a, b, c tapes sur le moniteur serie (115200 bauds)
 *   sont envoyes comme touches PS/2.
 *
 * Bibliotheques locales (dans ce repertoire) :
 *   ps2dev.h / ps2dev.cpp : PS/2 (https://github.com/Harvie/ps2dev)
 *   nes.h / nes.cpp       : manette NES (Daniel Fanara)
 *
 * ---------------- Cablage Arduino Nano ----------------
 *  D0 / D1 : reserves au port serie USB (moniteur serie) -> NE PAS UTILISER
 *
 *  PS/2 (mini-DIN 6 cote hote / emulateur) :
 *    D2  -> CLOCK  (mini-DIN broche 5)
 *    D3  -> DATA   (mini-DIN broche 1)
 *    5V  -> VCC    (mini-DIN broche 4)
 *    GND -> GND    (mini-DIN broche 3)
 *
 *  Manette DB9 n°1 :                 Manette DB9 n°2 :
 *    D4  -> broche 1 : Haut            A0 -> broche 1 : Haut
 *    D5  -> broche 2 : Bas             A1 -> broche 2 : Bas
 *    D6  -> broche 3 : Gauche          A2 -> broche 3 : Gauche
 *    D7  -> broche 4 : Droite          A3 -> broche 4 : Droite
 *    D8  -> broche 6 : Feu 1           A4 -> broche 6 : Feu 1
 *    D9  -> broche 9 : Feu 2           A5 -> broche 9 : Feu 2
 *    GND -> broche 8 : Masse           GND -> broche 8 : Masse
 *
 *  Manette NES (connecteur 7 broches) :
 *    5V  -> VCC
 *    GND -> GND
 *    D10 -> LATCH (strobe)
 *    D11 -> CLOCK (pulse)
 *    D12 -> DATA
 *  (D13 = LED integree, non utilisee)
 *
 *  DB9 : contacts vers la masse, LOW = appuye (INPUT_PULLUP).
 *  NES : DATA en INPUT_PULLUP -> manette absente = aucun bouton appuye.
 *
 *  Remarque : sur une manette Amstrad d'origine, Feu 1 est sur la broche 7
 *  et Feu 2 sur la broche 6 ; adapter le cablage si besoin.
 * ------------------------------------------------------
 */

#include "ps2dev.h"
#include "nes.h"

/* ---------- Options ---------- */
#define SERIAL_DEBUG 1                  // 1 = affiche les evenements touches sur le moniteur serie
#define NES_ENABLED  1                  // 0 = desactive la lecture de la manette NES
const unsigned long DEBOUNCE_MS     = 10;  // duree de stabilite pour valider un changement
const unsigned long NES_INTERVAL_MS = 5;   // periode de lecture de la manette NES

/* ---------- Broches ---------- */
const uint8_t PS2_CLK_PIN  = 2;
const uint8_t PS2_DATA_PIN = 3;

const uint8_t NES_LATCH_PIN = 10;
const uint8_t NES_CLOCK_PIN = 11;
const uint8_t NES_DATA_PIN  = 12;

/* ---------- Peripheriques ---------- */
PS2dev keyboard(PS2_CLK_PIN, PS2_DATA_PIN);              // clock, data
unsigned char leds = 0;                                  // etat des LEDs envoye par l'hote

#if NES_ENABLED
Controller nes(NES_LATCH_PIN, NES_CLOCK_PIN, NES_DATA_PIN); // latch, pulse, data
#endif

/* ======================================================================
 *  Touches PS/2 (sorties)
 * ====================================================================== */
struct KeyOut {
  uint8_t     scancode;  // scancode PS/2 (set 2)
  bool        extended;  // true = touche etendue (prefixe 0xE0)
  const char *name;      // nom pour le debug serie
  bool        sent;      // etat actuellement envoye a l'hote (appuye / relache)
};

// Index des touches logiques
enum {
  // Joueur 1 (DB9 n°1 + NES)
  K1_UP, K1_DOWN, K1_LEFT, K1_RIGHT, K1_FIRE1, K1_FIRE2, K1_START, K1_SELECT,
  // Joueur 2 (DB9 n°2)
  K2_UP, K2_DOWN, K2_LEFT, K2_RIGHT, K2_FIRE1, K2_FIRE2,
  KEY_COUNT
};

KeyOut keys[KEY_COUNT] = {
  // Joueur 1 - CPCESP joystick 1
  { PS2dev::UP_ARROW,    true,  "J1 Haut",   false },
  { PS2dev::DOWN_ARROW,  true,  "J1 Bas",    false },
  { PS2dev::LEFT_ARROW,  true,  "J1 Gauche", false },
  { PS2dev::RIGHT_ARROW, true,  "J1 Droite", false },
  { PS2dev::RIGHT_ALT,   true,  "J1 Feu1",   false },
  { PS2dev::LEFT_ALT,    false, "J1 Feu2",   false },
  { PS2dev::ENTER,       false, "J1 Start",  false },  // NES START
  { PS2dev::F1,          false, "J1 Select", false },  // NES SELECT
  // Joueur 2 - CPCESP joystick 2 natif (6,5,R,T + G/F)
  { PS2dev::SIX,         false, "J2 Haut",   false },
  { PS2dev::FIVE,        false, "J2 Bas",    false },
  { PS2dev::R,           false, "J2 Gauche", false },
  { PS2dev::T,           false, "J2 Droite", false },
  { PS2dev::G,           false, "J2 Feu1",   false },
  { PS2dev::F,           false, "J2 Feu2",   false }
};

// Etat demande par les entrees a chaque tour de boucle
bool keyWanted[KEY_COUNT];

// Etat d'anti-rebond d'une entree (declare avant toute fonction pour
// les prototypes generes automatiquement par l'IDE Arduino)
struct Debounce {
  bool          pressed;    // etat valide
  bool          lastRaw;    // derniere lecture brute
  unsigned long lastChange; // instant du dernier changement brut
};

void sendKey(const KeyOut &k, bool press)
{
  if (k.extended) {
    if (press) keyboard.keyboard_press_special(k.scancode);
    else       keyboard.keyboard_release_special(k.scancode);
  } else {
    if (press) keyboard.keyboard_press(k.scancode);
    else       keyboard.keyboard_release(k.scancode);
  }
}

/* Envoie uniquement les changements d'etat (appui / relachement) */
void keysUpdate()
{
  for (uint8_t i = 0; i < KEY_COUNT; i++) {
    if (keyWanted[i] != keys[i].sent) {
      keys[i].sent = keyWanted[i];
      sendKey(keys[i], keyWanted[i]);
#if SERIAL_DEBUG
      Serial.print(keys[i].name);
      Serial.println(keyWanted[i] ? F(" appuye") : F(" relache"));
#endif
    }
  }
}

/* ======================================================================
 *  Anti-rebond generique
 * ====================================================================== */
bool debounceUpdate(Debounce &d, bool raw, unsigned long now)
{
  if (raw != d.lastRaw) {        // changement brut : on relance le chrono
    d.lastRaw    = raw;
    d.lastChange = now;
  }
  if ((raw != d.pressed) && (now - d.lastChange >= DEBOUNCE_MS)) {
    d.pressed = raw;             // stable depuis DEBOUNCE_MS -> valide
  }
  return d.pressed;
}

/* ======================================================================
 *  Manettes DB9
 * ====================================================================== */
struct DB9Input {
  uint8_t  pin;   // broche Arduino
  uint8_t  key;   // touche logique associee
  Debounce db;
};

#define DB9_INPUT_COUNT 12
DB9Input db9[DB9_INPUT_COUNT] = {
  // DB9 n°1 -> joueur 1
  { 4,  K1_UP,    {false, false, 0} },
  { 5,  K1_DOWN,  {false, false, 0} },
  { 6,  K1_LEFT,  {false, false, 0} },
  { 7,  K1_RIGHT, {false, false, 0} },
  { 8,  K1_FIRE1, {false, false, 0} },
  { 9,  K1_FIRE2, {false, false, 0} },
  // DB9 n°2 -> joueur 2
  { A0, K2_UP,    {false, false, 0} },
  { A1, K2_DOWN,  {false, false, 0} },
  { A2, K2_LEFT,  {false, false, 0} },
  { A3, K2_RIGHT, {false, false, 0} },
  { A4, K2_FIRE1, {false, false, 0} },
  { A5, K2_FIRE2, {false, false, 0} }
};

void db9Init()
{
  for (uint8_t i = 0; i < DB9_INPUT_COUNT; i++) {
    pinMode(db9[i].pin, INPUT_PULLUP);
  }
}

void db9Read(unsigned long now)
{
  for (uint8_t i = 0; i < DB9_INPUT_COUNT; i++) {
    bool raw = (digitalRead(db9[i].pin) == LOW);   // LOW = appuye
    if (debounceUpdate(db9[i].db, raw, now)) {
      keyWanted[db9[i].key] = true;
    }
  }
}

/* ======================================================================
 *  Manette NES (joueur 1)
 * ====================================================================== */
#if NES_ENABLED
struct NESInput {
  uint8_t  button;  // BTN_xxx de nes.h
  uint8_t  key;     // touche logique associee
  Debounce db;
};

#define NES_INPUT_COUNT 8
NESInput nesInputs[NES_INPUT_COUNT] = {
  { BTN_UP,     K1_UP,     {false, false, 0} },
  { BTN_DOWN,   K1_DOWN,   {false, false, 0} },
  { BTN_LEFT,   K1_LEFT,   {false, false, 0} },
  { BTN_RIGHT,  K1_RIGHT,  {false, false, 0} },
  { BTN_A,      K1_FIRE1,  {false, false, 0} },
  { BTN_B,      K1_FIRE2,  {false, false, 0} },
  { BTN_START,  K1_START,  {false, false, 0} },
  { BTN_SELECT, K1_SELECT, {false, false, 0} }
};

unsigned long nesLastRead = 0;

void nesRead(unsigned long now)
{
  // Nouvelle lecture du registre a decalage toutes les NES_INTERVAL_MS
  if (now - nesLastRead >= NES_INTERVAL_MS) {
    nesLastRead = now;
    nes.latch();
  }
  // Les derniers etats lus passent par l'anti-rebond
  for (uint8_t i = 0; i < NES_INPUT_COUNT; i++) {
    bool raw = nes.pressed(nesInputs[i].button);
    if (debounceUpdate(nesInputs[i].db, raw, now)) {
      keyWanted[nesInputs[i].key] = true;
    }
  }
}
#endif

/* ======================================================================
 *  Lecture de toutes les manettes + envoi PS/2
 * ====================================================================== */
void joysticksProcess()
{
  unsigned long now = millis();

  for (uint8_t i = 0; i < KEY_COUNT; i++) keyWanted[i] = false;

  db9Read(now);        // DB9 n°1 (joueur 1) + DB9 n°2 (joueur 2)
#if NES_ENABLED
  nesRead(now);        // NES (joueur 1) - combine avec DB9 n°1 (OU logique)
#endif

  keysUpdate();        // envoi des appuis / relachements PS/2
}

/* ======================================================================
 *  Test serie : a, b, c
 * ====================================================================== */
unsigned char charToScancode(char c)
{
  switch (c) {
    case 'a': case 'A': return PS2dev::A;
    case 'b': case 'B': return PS2dev::B;
    case 'c': case 'C': return PS2dev::C;
    default:            return 0;
  }
}

void serialProcess()
{
  if (!Serial.available()) return;

  char c = Serial.read();
  if (c == '\r' || c == '\n') return;  // ignorer fins de ligne

  unsigned char code = charToScancode(c);
  if (code) {
    keyboard.keyboard_press(code);
    delay(20);
    keyboard.keyboard_release(code);

    Serial.print(F("Touche envoyee : "));
    Serial.print(c);
    Serial.print(F(" (scancode 0x"));
    Serial.print(code, HEX);
    Serial.println(F(")"));
  } else {
    Serial.print(F("Caractere non gere : "));
    Serial.println(c);
  }
}

/* ======================================================================
 *  Programme principal
 * ====================================================================== */
void setup()
{
  Serial.begin(115200);

  // Entrees des 2 manettes DB9 avec pull-up internes
  db9Init();
  // (la manette NES est initialisee par le constructeur Controller)

  // Initialisation clavier PS/2 (envoie 0xAA = self-test OK)
  keyboard.keyboard_init();

  Serial.println(F("DB9 x2 + NES -> PS/2 (Nano) - mode CPCESP"));
  Serial.println(F("Test serie : tapez a, b ou c puis Entree."));
}

bool reinitDone = false;

void loop()
{
  // Relance l'initialisation PS/2 une fois après 2,5s pour synchroniser avec le démarrage de l'ESP32
  if (!reinitDone && millis() > 2500) {
    keyboard.keyboard_init();
    reinitDone = true;
  }

  // Repondre aux commandes de l'hote PS/2 (reset, LEDs, ID...)
  keyboard.keyboard_handle(&leds);

  // Lecture des manettes (DB9 x2 + NES) et envoi des touches
  joysticksProcess();

  // Test via le moniteur serie
  serialProcess();
}
