#!/usr/bin/env python3

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('Gdk', '3.0')
from gi.repository import Gtk, Gdk
import subprocess

CSS = b"""
window {
    background-color: #15161E;
    border-radius: 12px;
}

scale {
    min-height: 12px;
    margin: 10px;
}

scale trough {
    background-color: #1A1B26;
    border-radius: 6px;
    min-height: 12px;
}

scale highlight {
    background-color: #7AA2F7;
    border-radius: 6px;
    min-height: 12px;
}

scale slider {
    background-color: #7AA2F7;
    border-radius: 50%;
    min-width: 22px;
    min-height: 22px;
    margin: -5px;
}

scale slider:hover {
    background-color: #89B4FA;
}

label {
    color: #C0CAF5;
    font-family: "SpaceMono Nerd Font", monospace;
    font-size: 12px;
    margin: 5px 15px;
}

.volume-icon {
    font-size: 24px;
    margin: 10px 15px 0 15px;
}
"""

def get_volume():
    try:
        result = subprocess.run(
            ['wpctl', 'get-volume', '@DEFAULT_AUDIO_SINK@'],
            capture_output=True, text=True
        )
        vol = float(result.stdout.split()[1]) * 100
        return int(vol)
    except:
        return 50

def set_volume(vol):
    subprocess.run(['wpctl', 'set-volume', '@DEFAULT_AUDIO_SINK@', f'{vol}%'])

def get_icon(vol):
    if vol >= 70:
        return "󰕾"
    elif vol >= 30:
        return "󰖀"
    elif vol > 0:
        return "󰕿"
    else:
        return "󰝟"

class VolumeWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title="Volume")
        self.set_default_size(280, 100)
        self.set_decorated(False)
        self.set_resizable(False)
        self.set_position(Gtk.WindowPosition.MOUSE)

        # Apply CSS
        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        # Main box
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.add(vbox)

        # Volume icon
        self.icon = Gtk.Label()
        self.icon.get_style_context().add_class('volume-icon')
        vbox.pack_start(self.icon, False, False, 0)

        # Slider
        current_vol = get_volume()
        self.adjustment = Gtk.Adjustment(value=current_vol, lower=0, upper=100, step_increment=5)
        self.scale = Gtk.Scale(orientation=Gtk.Orientation.HORIZONTAL, adjustment=self.adjustment)
        self.scale.set_draw_value(False)
        self.scale.connect('value-changed', self.on_value_changed)
        vbox.pack_start(self.scale, True, True, 0)

        # Percentage label
        self.label = Gtk.Label(label=f"{current_vol}%")
        vbox.pack_start(self.label, False, False, 0)

        self.update_icon(current_vol)

        # Close on focus loss
        self.connect('focus-out-event', Gtk.main_quit)
        self.connect('key-press-event', self.on_key_press)

    def update_icon(self, vol):
        self.icon.set_text(get_icon(vol))

    def on_value_changed(self, scale):
        vol = int(scale.get_value())
        set_volume(vol)
        self.label.set_text(f"{vol}%")
        self.update_icon(vol)

    def on_key_press(self, widget, event):
        if event.keyval in (Gdk.KEY_Escape, Gdk.KEY_Return, Gdk.KEY_KP_Enter):
            Gtk.main_quit()

win = VolumeWindow()
win.connect('destroy', Gtk.main_quit)
win.show_all()
Gtk.main()
