# G3 Flex pan turntable (28BYJ-48, 5:1 internal gear) — simple sliding version, dupont-ready

Parametric source: `g3flex_pan_turntable.scad` (select `part` in the Customizer).

| Plate | Orientation on bed | Contents |
|---|---|---|
| `stl/base_housing.stl` | floor down | housing, sliding ledge, motor screw bosses, PCB mounts, hard-stop posts |
| `stl/rotating_cup.stl` | as plated | rotor (deck down) + G3 Flex cup adapter (flange down) |
| `stl/pinion_14t_m1.stl` | flat, either side | 14T module-1 pinion for the 28BYJ-48 (Ø5 double-flat bore). Print it if your existing pinion isn't 14T m1. |
| `stl/platform_adapter.stl` | optional | flat Ø86 platform (4× M3 on Ø78) for other payloads |

PETG, 0.2 mm layers, 3–4 perimeters, no supports.

## Hardware
- 28BYJ-48 + your 14T m1 pinion, 2× M3×8 self-tapping (ears)
- ULN2003 board, 4× M3×6 self-tapping (or M2.5)
- ESP32-S3 SuperMini with headers pointing down and dupont plugs on them (sits high on a centre fin, USB-C at the rear)
- No bearings or balls. Optionally a dab of PTFE or silicone grease in the ledge groove
- 4× M3×8 countersunk (cup adapter → rotor), 1× M3×10 grub screw (or M3×12 thumb screw) + M3 nut
- 3× ~3.5 mm countersunk wood screws (optional base mounting)

## Assembly
1. Optional: screw the base to the shelf first. The countersunk heads end flush, so the motor and PCBs can sit over them.
2. Plug the duponts onto the ESP32 first. Slide its USB-C end into the wall pocket, then press the other end down until the rear clip snaps over the PCB. Let the wires turn inward under the board alongside the clip. Screw on the ULN2003 with its input header on the edge facing the centre. Screw the motor to the bosses with the pinion up; the two ears should lie flat on the bosses before tightening. The motor can hangs clear of the floor. Coil the spare motor lead and tie it below the ledge, out of the path of the rotor's stop lug.
3. Optional: put a thin film of grease in the ledge groove.
4. Turn the rotor so its stop lug (opposite the pinion) points to −X, then drop it into the base rim. Gravity holds it down; the 1.5 mm rim engagement keeps it centred.
5. Screw the cup adapter onto the rotor with the slot at the rear. Insert the camera, then tighten the front set screw.
6. Firmware: the 28BYJ-48's real gear ratio is about 63.68:1, which gives about 2038 full steps per motor turn and about 10189 per rotor turn (often quoted as 2048 / 10240). Expect about 0.7° of play from gear backlash. Home softly against a hard stop, or set your limits inside ±115°.

## Notes
- Total height is 73.4 mm, with the camera seat at 45.4 mm. This revision adds 7 mm to the base for the ESP32 wiring. It allows 12 mm below the modeled 12 mm plug housings for the wires to turn inward. The existing rotor, cup and pinion fit this revision.
- There's a gap of about 39° in the sliding ledge at the rear. That's the full-height bay for the ESP32; the rotor rim slides across it.
- The flat pad on the outside behind the USB-C keeps the wall at least 1 mm thick there. It sticks out up to 1.9 mm past the 92 mm circle.
- The only flat bridge is the 9.5 mm span over the USB-C cutout. Every other downward-facing surface is at 45° or steeper.
- `usb_recess` (0.8 mm) sets how far the receptacle sits behind the flat pad.
- `dupont_len`, `dupont_wire_bend` and `esp_row_x` describe your plugs and board. Measure them and re-export if yours differ.
