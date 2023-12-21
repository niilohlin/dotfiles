/* Copyright 2020 ZSA Technology Labs, Inc <@zsa>
 * Copyright 2020 Jack Humbert <jack.humb@gmail.com>
 * Copyright 2020 Christopher Courtney, aka Drashna Jael're  (@drashna) <drashna@live.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */



#include QMK_KEYBOARD_H
#include "version.h"

enum layers {
    BASE,  // default layer
    SYMB,  // symbols
    MDIA,  // media keys
};

enum custom_keycodes {
    VRSN = SAFE_RANGE,
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [BASE] = LAYOUT(
        KC_DLR,  KC_AMPR, KC_LBRC, KC_LCBR, KC_RCBR, KC_LPRN, _______,          KC_HASH, KC_EQL,  KC_ASTR, KC_RPRN, KC_PLUS, KC_RBRC, KC_EXLM,
        KC_MINS, KC_Q,    KC_D,    KC_R,    KC_W,    KC_B,    TG(SYMB),         KC_DEL,  KC_J,    KC_F,    KC_U,    KC_P,    KC_SCLN, KC_SLSH,
        KC_LSFT, KC_A,    KC_S,    KC_H,    KC_T,    KC_G,    KC_TAB,           KC_TAB,  KC_Y,    KC_N,    KC_E,    KC_O,    KC_I,    KC_RSFT,
        KC_LCTL, KC_Z,    KC_X,    KC_M,    KC_C,    KC_V,                               KC_K,    KC_L,    KC_COMM, KC_DOT,  KC_QUOT, KC_RCTL,
        KC_LALT, CW_TOGG, KC_BSLS, KC_LEFT, KC_RGHT,          KC_BSPC,          KC_BSPC,          KC_UP,   KC_DOWN, KC_AT,   _______, KC_RALT,
                                            KC_LGUI, KC_ENT,  KC_ESC,           KC_ESC,  KC_ENT,  KC_SPC
    ),

    [SYMB] = LAYOUT(
        VRSN,    KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   _______,           _______, KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_F11,
        _______, KC_EXLM, KC_AT,   KC_LCBR, KC_RCBR, KC_PIPE, _______,           _______, KC_UP,   KC_7,    KC_8,    KC_9,    KC_ASTR, KC_F12,
        _______, KC_HASH, KC_DLR,  KC_LPRN, KC_RPRN, KC_GRV,  _______,           _______, KC_DOWN, KC_4,    KC_5,    KC_6,    KC_PLUS, _______,
        _______, KC_PERC, KC_CIRC, KC_LBRC, KC_RBRC, KC_TILD,                             KC_AMPR, KC_1,    KC_2,    KC_3,    KC_BSLS, _______,
        EE_CLR,  _______, _______, _______, _______,          RGB_VAI,           RGB_TOG,          _______, KC_DOT,  KC_0,    KC_EQL,  _______,
                                            RGB_HUD, RGB_VAD, RGB_HUI, TOGGLE_LAYER_COLOR,_______, _______
    ),

    [MDIA] = LAYOUT(
        LED_LEVEL,_______,_______, _______, _______, _______, _______,           _______, _______, _______, _______, _______, _______, QK_BOOT,
        _______, _______, _______, KC_MS_U, _______, _______, _______,           _______, _______, _______, _______, _______, _______, _______,
        _______, _______, KC_MS_L, KC_MS_D, KC_MS_R, _______, _______,           _______, _______, _______, _______, _______, _______, KC_MPLY,
        _______, _______, _______, _______, _______, _______,                             _______, _______, KC_MPRV, KC_MNXT, _______, _______,
        _______, _______, _______, KC_BTN1, KC_BTN2,         _______,            _______,          KC_VOLU, KC_VOLD, KC_MUTE, _______, _______,
                                            _______, _______, _______,           _______, _______, _______
    ),
};

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (record->event.pressed) {
        switch (keycode) {
        case VRSN:
            SEND_STRING (QMK_KEYBOARD "/" QMK_KEYMAP " @ " QMK_VERSION);
            return false;
        }
    }
    return true;
}

const key_override_t tilde      = ko_make_basic(MOD_MASK_SHIFT, KC_DLR,  KC_TILD);
const key_override_t percent    = ko_make_basic(MOD_MASK_SHIFT, KC_AMPR, KC_PERC);
const key_override_t seven      = ko_make_basic(MOD_MASK_SHIFT, KC_LBRC, KC_7);
const key_override_t five       = ko_make_basic(MOD_MASK_SHIFT, KC_LCBR, KC_5);
const key_override_t three      = ko_make_basic(MOD_MASK_SHIFT, KC_RCBR, KC_3);
const key_override_t one        = ko_make_basic(MOD_MASK_SHIFT, KC_LPRN, KC_1);
const key_override_t backtick   = ko_make_basic(MOD_MASK_SHIFT, KC_HASH, KC_GRV);
const key_override_t nine       = ko_make_basic(MOD_MASK_SHIFT, KC_EQL,  KC_9);
const key_override_t zero       = ko_make_basic(MOD_MASK_SHIFT, KC_ASTR, KC_0);
const key_override_t two        = ko_make_basic(MOD_MASK_SHIFT, KC_RPRN, KC_2);
const key_override_t four       = ko_make_basic(MOD_MASK_SHIFT, KC_PLUS, KC_4);
const key_override_t six        = ko_make_basic(MOD_MASK_SHIFT, KC_RBRC, KC_6);
const key_override_t eight      = ko_make_basic(MOD_MASK_SHIFT, KC_EXLM, KC_8);


const key_override_t **key_overrides = (const key_override_t *[]){
    &tilde,
    &percent,
    &seven,
    &five,
    &three,
    &one,
    &backtick,
    &nine,
    &zero,
    &two,
    &four,
    &six,
    &eight,
	NULL // Null terminate the array of overrides!
};
