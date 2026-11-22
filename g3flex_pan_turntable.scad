// =====================================================================
//  G3 Flex motorized pan turntable  (28BYJ-48 + 14T/70T internal gear)
//  Simple version: no bearings, no snap hooks.
//  The rotor works like a lid: its ring-gear rim slides on a printed
//  PETG ledge, and the deck edge is centred by the base rim.
//  Sized for dupont-wired electronics: the ESP32-S3 sits high on a
//  centre fin with plugs on its down-facing headers, in a gap in the
//  sliding ledge at the rear.
//  Parametric OpenSCAD — PETG, Prusa MK3S+, 0.4 nozzle, 0.2 layers,
//  no supports.  All dimensions in mm.
//
//  Print plates (select with `part`):
//    base_housing  -> base_housing.stl  (floor on bed)
//    rotating_cup  -> rotating_cup.stl  (rotor deck-down + cup flange-down,
//                                        joined with 4x M3x8 after printing)
//  Optional: rotor, cup_adapter, platform_adapter
//
//  Rotor and cup are separate bodies because the gear hangs DOWN from the
//  deck and the socket stands UP; each body prints flat on its own face.
//  The rotor top (4x M3 on PCD 78) takes other cups / platforms.
// =====================================================================

/* [View] */
part = "assembly"; // [assembly, section_xz, section_yz, base_housing, rotating_cup, rotor, cup_adapter, platform_adapter, pinion, check_rotor_static, check_gear_mesh, check_gear_shifted, check_base_parts, check_cup_rotor]
exploded_view = false;
explode_dist = 30;
// Pan angle for the assembly / checks (home = 0, camera faces +Y). Keep within ±sweep_angle/2.
rotor_angle = 0; // [-115:1:115]
show_hardware = true;
show_camera = true;

/* [Gearing] */
gear_module = 1.0;
pinion_teeth = 14;
ring_teeth = 70;
pressure_angle = 20;
// Pinion pulled toward the centre by this much (backlash). Keep > rim_radial_clear.
gear_backlash_radial = 0.30;
ring_tooth_h = 8.0;
ring_tooth_extra_play = 0.0;
// Gap between motor can top and pinion bottom on your build
pinion_gap_above_can = 1.5;
pinion_face = 10.0;
// Printed pinion bore: 28BYJ-48 shaft is Ø5 with flats 3.0 apart
pinion_bore_d = 5.15;
pinion_bore_flats = 3.1;

/* [Motion] */
sweep_angle = 230;
stop_post_half_ang = 6;
stop_lug_half_ang = 5;

/* [Housing] */
base_od = 92.0;
wall_t = 2.4;
floor_t = 2.4;
// Motor clearance above the floor before the extra ESP32 wiring allowance
motor_lift = 2.0;
// Radial clearance between rotor deck edge and base rim (centring fit)
rim_radial_clear = 0.20;
// How deep the rotor deck sits inside the base rim
rim_engagement = 1.5;

/* [Camera cup] */
camera_dia = 48.35;
cup_wall_h = 28.0;
cup_wall_t = 2.4;
slot_w = 16.0;
slot_depth = 22.0;
setscrew_z = 14.0;
flange_t = 3.0;

/* [Rotor interface] */
iface_flange_d = 86.0;
iface_bolt_pcd = 78.0;
iface_pilot_d = 2.6;
iface_pilot_depth = 7.0;

/* [Electronics] */
uln_pos = [-17, 0];
uln_board = [32, 35];
uln_hole_pattern = [27, 30];
uln_height = 12.0;
uln_standoff_h = 2.5;
uln_standoff_hole = 2.6;
// ULN input header (with duponts) sits on the board edge facing the centre
uln_hdr_box = [4.5, 12];
esp_board = [18.0, 22.5];
esp_pcb_t = 1.0;
esp_usb_h = 3.2;
esp_usb_len = 7.3;
esp_usb_overhang = 0.5;
// Height of top-side parts other than the USB-C (chip, buttons, LED)
esp_comp_h = 2.0;
// Header geometry under the board: plastic spacer + dupont housing + wire bend
esp_hdr_spacer = 2.5;
dupont_len = 12.0;
// Clearance below the ESP32 plugs
dupont_wire_bend = 12.0;
uln_wire_bend = 5.0;
esp_row_x = 7.62;        // pin-row offset from the board centreline
// Receptacle face sits this far behind the flat USB pad on the outside
usb_recess = 0.8;
usb_cut = [9.5, 3.8];
usb_pad_w = 26;

/* [Mounting] */
mount_hole_angles = [100, 220, 340];
mount_hole_r = 26;
mount_csk_d = 6.0;
mount_shank_d = 3.4;

/* [Hidden] */
$fa = 2; $fs = 0.4;
fnb = 240;
eps = 0.01;

// ---------------------------------------------------------------------
//  Derived geometry
// ---------------------------------------------------------------------
R_out = base_od/2;
R_in  = R_out - wall_t;
R_deck = R_in - rim_radial_clear;

ring_pr = gear_module*ring_teeth/2;
pin_pr  = gear_module*pinion_teeth/2;
ring_tip_r  = ring_pr - gear_module;
ring_root_r = ring_pr + 1.25*gear_module;
pin_tip_r   = pin_pr + gear_module;
center_dist = ring_pr - pin_pr - gear_backlash_radial;
ring_out_r  = ring_root_r + 5.75;   // gear rim = sliding foot

can_d = 28; can_h = 19; ear_spacing = 35; ear_t = 1.0; ear_hole = 4.2;
shaft_off = 8; shaft_d = 5; shaft_boss_d = 9; shaft_boss_h = 1.5;
wirebox = [8, 14.6, 16.5];
ear_boss_d = 6.4;
motor_c = [center_dist - shaft_off, 0];

// Raise the existing drive and board layout together to gain wiring room.
base_extra_h = max(0, dupont_wire_bend - 5.0);
z_can_bot = floor_t + base_extra_h + motor_lift;
z_can_top = z_can_bot + can_h;
z_pin0 = z_can_top + pinion_gap_above_can;
z_pin1 = z_pin0 + pinion_face;
z_d0 = z_pin1 + 0.5;            // deck underside
deck_t = 3.0;
z_d1 = z_d0 + deck_t;           // deck top = camera seat
z_c0 = z_d0 - ring_tooth_h;     // gear rim bottom = sliding face
z_L  = z_c0;                    // ledge top
z_rim = z_d0 + rim_engagement;  // base rim top
ledge_in = max(ring_tip_r + 1.5, center_dist + pin_tip_r + 0.5);
cone_A = z_L - 1.6 + ledge_in;  // 45-deg cone under the ledge: z = cone_A - r
function cone_z(r) = cone_A - r;

post_r0 = ring_tip_r - 5.5; post_r1 = ring_tip_r - 1.0;
a_post = 180 - sweep_angle/2 - stop_lug_half_ang - stop_post_half_ang;
post_top = z_c0 + 5.5;

// ESP32: PCB height set by the dupont stack under it
esp_pcb_z0 = floor_t + dupont_wire_bend + dupont_len + esp_hdr_spacer;
esp_pcb_z1 = esp_pcb_z0 + esp_pcb_t;
esp_usb_zc = esp_pcb_z1 + esp_usb_h/2;
esp_top = esp_pcb_z1 + max(esp_comp_h, esp_usb_h);
pad_y = -R_out;                                 // flat outer face of USB pad
esp_front_y = pad_y + usb_recess + esp_usb_overhang;  // PCB front edge
esp_back_y = esp_front_y + esp_board[1];
ledge_gap_half = asin((esp_board[0]/2 + 1.8)/ledge_in) + 2;
uln_z0 = floor_t + base_extra_h + uln_standoff_h;
uln_top = uln_z0 + uln_height;
total_h = z_d1 + cup_wall_h;

// ---------------------------------------------------------------------
//  Design-rule checks
// ---------------------------------------------------------------------
uln_corner_r = norm([abs(uln_pos[0]) + uln_board[0]/2, uln_board[1]/2]);
post_mid = (post_r0 + post_r1)/2;
post_half_w = norm([post_mid*sin(stop_post_half_ang), (post_r1 - post_r0)/2]);   // bounding circle
boss_post_gap = norm([motor_c[0], ear_spacing/2] - post_mid*[cos(a_post), sin(a_post)]) - 7/2 - post_half_w;   // vs motor ear
pilot_wall = min(iface_bolt_pcd/2 - iface_pilot_d/2 - ring_root_r, ring_out_r - iface_bolt_pcd/2 - iface_pilot_d/2);
pinion_half_ang = asin(pin_tip_r/center_dist);

assert(center_dist + pin_tip_r < ring_root_r, "pinion tip hits ring root");
assert(center_dist + pin_tip_r + 0.4 < ledge_in, "pinion hits ledge");
assert(motor_c[0] + can_d/2 + 1 < ledge_in, "motor can hits ledge");
assert(z_pin1 < z_d0, "pinion hits deck");
assert(z_L > z_can_top + 1, "ledge too low over motor ears");
assert(gear_backlash_radial > rim_radial_clear + 0.05, "rim play can jam the gears");
assert(cone_z(uln_corner_r) > uln_top + 0.5, "ULN2003 hits ledge cone");
assert(esp_top < z_c0 - 0.8, "ESP32 hits rotor ring");
assert(a_post - stop_post_half_ang > pinion_half_ang + 4, "stop post too close to pinion");
assert(post_r1 < ring_tip_r - 0.8, "stop post hits ring teeth");
assert(post_top < z_d0 - 1, "stop post hits deck");
assert(boss_post_gap > 0, "stop post hits motor ear (exact test: part=check_base_parts)");
assert(pilot_wall > 0.9, "adapter pilot holes too close to gear / rim");
assert(iface_flange_d/2 <= R_deck, "adapter flange wider than rotor");
assert(ring_out_r < R_in - 1, "gear rim too close to base wall");
assert(uln_pos[0] + uln_board[0]/2 + 2 < motor_c[0] - can_d/2 - (17 - can_d/2), "ULN2003 hits motor wire box");
assert(uln_pos[1] - uln_board[1]/2 > esp_back_y + 2, "ULN2003 hits ESP32");

echo("== G3 Flex pan turntable (sliding, dupont-ready) ==");
echo(str("gear centre distance ", center_dist, "  ratio 1:", ring_teeth/pinion_teeth, "  pinion tip r ", center_dist + pin_tip_r, "  ledge_in ", ledge_in));
echo(str("pinion z ", z_pin0, "..", z_pin1, "  ring teeth z ", z_c0, "..", z_d0, "  engagement ", z_pin1 - z_c0));
echo(str("sliding ring r ", ring_root_r, "..", ring_out_r, " on ledge z ", z_L, "  rear ledge gap +/-", ledge_gap_half, " deg"));
echo(str("ESP PCB z ", esp_pcb_z0, "..", esp_pcb_z1, "  top ", esp_top, "  USB centre z ", esp_usb_zc, "  ring bottom ", z_c0));
echo(str("ULN corner cone ", cone_z(uln_corner_r), " vs ULN top ", uln_top, "  ULN dupont top ", uln_z0 + 1.6 + esp_hdr_spacer + dupont_len + uln_wire_bend));
echo(str("stop posts +/-", a_post, " deg, boss gap ", boss_post_gap, "  pilot wall ", pilot_wall));
echo(str("base height ", z_rim, "  rotor top ", z_d1, "  TOTAL HEIGHT ", total_h));

// ---------------------------------------------------------------------
//  Helpers
// ---------------------------------------------------------------------
function inv_rad(a) = tan(a) - a*PI/180;
function gear_pts(N, m, pa, add, ded, thin=0, steps=8) =
  let(rp = m*N/2, rb = rp*cos(pa), ra = rp + add, rf = rp - ded,
      psi_p = PI/(2*N) - thin/(2*rp), r0 = max(rb, rf),
      fl = [for (i=[0:steps]) let(r = r0 + (ra - r0)*i/steps, al = acos(min(1, rb/r)))
              [r, (psi_p + inv_rad(pa) - inv_rad(al))*180/PI]])
  [for (k=[0:N-1]) let(t = k*360/N) each concat(
      rf < rb ? [rf*[cos(t - fl[0][1]), sin(t - fl[0][1])]] : [],
      [for (p = fl) p[0]*[cos(t - p[1]), sin(t - p[1])]],
      [for (i = [steps:-1:0]) fl[i][0]*[cos(t + fl[i][1]), sin(t + fl[i][1])]],
      rf < rb ? [rf*[cos(t + fl[0][1]), sin(t + fl[0][1])]] : [])];

module sector(r0, r1, a0, a1, h) {
  n = 16;
  linear_extrude(h) polygon(concat(
    [for (i=[0:n]) r1*[cos(a0 + (a1-a0)*i/n), sin(a0 + (a1-a0)*i/n)]],
    [for (i=[n:-1:0]) r0*[cos(a0 + (a1-a0)*i/n), sin(a0 + (a1-a0)*i/n)]]));
}
module tube(r0, r1, h) difference() { cylinder(r=r1, h=h); translate([0,0,-eps]) cylinder(r=r0, h=h+2*eps); }
module teardrop2d(r) union() { circle(r); polygon([[-r/sqrt(2), r/sqrt(2)], [0, r*sqrt(2)], [r/sqrt(2), r/sqrt(2)]]); }
module yz_extrude(len) rotate([90,0,90]) linear_extrude(len, center=true) children();

// ---------------------------------------------------------------------
//  PART 1 — base housing
// ---------------------------------------------------------------------
function base_profile() = [
  [0, 0], [R_out, 0], [R_out, z_rim], [R_in, z_rim], [R_in, z_L],
  [ledge_in, z_L], [ledge_in, cone_z(ledge_in)], [R_in, cone_z(R_in)],
  [R_in, floor_t], [0, floor_t]];

module base_housing() {
  difference() {
    union() {
      difference() {
        rotate_extrude($fn=fnb) polygon(base_profile());
        // rear gap in the ledge + cone: full-height bay for the ESP32
        // starts above the floor and bites 0.3 into the wall so no faces coincide
        translate([0,0,cone_z(R_in) - 1]) sector(ledge_in - 1, R_in + 0.3, 270 - ledge_gap_half, 270 + ledge_gap_half, z_L - cone_z(R_in) + 2);
      }
      usb_pad();
      motor_mount();
      uln_standoffs();
      esp_mount();
      stop_posts();
    }
    rotate_extrude($fn=fnb) polygon([[ring_root_r + 1.2, z_L + eps], [ring_root_r + 1.9, z_L - 0.7], [ring_root_r + 2.6, z_L + eps]]);
    for (a = mount_hole_angles) rotate(a) translate([mount_hole_r, 0, 0]) {
      translate([0,0,-eps]) cylinder(d=mount_shank_d, h=floor_t + 1);
      translate([0,0,floor_t - (mount_csk_d - mount_shank_d)/2 - 0.2]) cylinder(d1=mount_shank_d, d2=mount_csk_d + 0.4, h=(mount_csk_d - mount_shank_d)/2 + 0.2 + eps);
    }
    for (s = [-1, 1]) translate([motor_c[0], s*ear_spacing/2, z_can_top - ear_t - 10]) cylinder(d=2.6, h=10 + eps);
    for (sx = [-1, 1], sy = [-1, 1]) translate([uln_pos[0] + sx*uln_hole_pattern[0]/2, uln_pos[1] + sy*uln_hole_pattern[1]/2, uln_z0 - uln_standoff_h - 1.8]) cylinder(d=uln_standoff_hole, h=uln_standoff_h + 1.8 + eps);
    esp_cuts();
  }
}

// flat pad on the outside behind the USB-C: keeps >=1 mm of wall behind the
// PCB corners and gives the plug overmold a flat face to seat on
module usb_pad() intersection() {
  translate([-usb_pad_w/2, pad_y, 0]) cube([usb_pad_w, R_out - R_in, esp_top + 4]);
  translate([0,0,-1]) cylinder(r=R_out + 3, h=z_rim + 2);
}

module motor_mount()
  for (s = [-1, 1])
    translate([motor_c[0], s*ear_spacing/2, floor_t - eps])
      cylinder(d=ear_boss_d, h=z_can_top - ear_t - floor_t + eps);

module uln_standoffs()
  for (sx = [-1, 1], sy = [-1, 1])
    translate([uln_pos[0] + sx*uln_hole_pattern[0]/2, uln_pos[1] + sy*uln_hole_pattern[1]/2, floor_t - eps])
      cylinder(d=6, h=uln_z0 - floor_t + eps);

// ESP32 mount: centre fin under the PCB (between the dupont rows), rear
// clip with a 45/45 nub, side locators; the front edge sits in the wall pocket
module esp_mount() {
  fin_w = 2*(esp_row_x - 1.3 - 1.0);   // clears the dupont housings by 1 mm
  translate([-fin_w/2, -R_in + 0.5, floor_t - eps]) cube([fin_w, R_in - 0.5 + esp_back_y - 0.5, esp_pcb_z0 - floor_t + eps]);
  // Hold the board between the two plug lanes so the wires can exit inward.
  translate([-5, esp_back_y + 0.2, floor_t - eps]) cube([10, 2.0, esp_pcb_z1 + 1.4 - floor_t + eps]);
  translate([0, esp_back_y + 0.2, 0]) yz_extrude(10)
    polygon([[eps, esp_pcb_z1 + 0.05], [-0.8, esp_pcb_z1 + 0.85], [eps, esp_pcb_z1 + 1.4]]);
  // side locators at the rear end (behind the last header pins)
  for (s = [-1, 1]) translate([s > 0 ? esp_board[0]/2 + 0.25 : -esp_board[0]/2 - 0.25 - 1.6, esp_back_y - 2.0, floor_t - eps])
    cube([1.6, 2.0 + 2.2, esp_pcb_z1 + 0.8 - floor_t + eps]);
}

module esp_cuts() {
  w = esp_board[0] + 0.5;
  // wall pocket for the PCB front edge, receptacle and front header pins;
  // the roof rises outward at 45 deg (no flat bridge)
  py = esp_front_y - 0.2; pz1 = esp_top + 0.3; yi = -(R_in - 1.5);
  yz_extrude(w) polygon([[yi, floor_t], [py, floor_t], [py, pz1 + (yi - py)], [yi, pz1]]);
  // USB-C cutout through wall + pad
  translate([-usb_cut[0]/2, pad_y - 1, esp_usb_zc - usb_cut[1]/2]) cube([usb_cut[0], 6, usb_cut[1]]);
}

module stop_posts()
  for (s = [-1, 1]) {
    a = s*a_post;
    translate([0,0,floor_t - eps]) sector(post_r0, post_r1, a - stop_post_half_ang, a + stop_post_half_ang, post_top - floor_t);
    // full-width web into the ledge cone (stays 1.2 below the ring and lug)
    translate([0,0,floor_t - eps]) sector(post_r1 - 0.5, R_in + 0.6, a - stop_post_half_ang + 0.6, a + stop_post_half_ang - 0.6, z_L - 1.2 - floor_t + eps);
  }

// ---------------------------------------------------------------------
//  PART 2a — rotor (assembly coords; printed deck-down)
// ---------------------------------------------------------------------
module rotor() {
  difference() {
    union() {
      translate([0,0,z_d0]) cylinder(r=R_deck, h=deck_t, $fn=fnb);
      translate([0,0,z_c0]) linear_extrude(z_d0 - z_c0 + eps) difference() {
        circle(r=ring_out_r, $fn=fnb);
        polygon(gear_pts(ring_teeth, gear_module, pressure_angle, 1.25*gear_module, gear_module, thin=-ring_tooth_extra_play));
      }
      translate([0,0,z_c0]) sector(post_r0 + 0.5, ring_root_r + 0.5, 180 - stop_lug_half_ang, 180 + stop_lug_half_ang, z_d0 - z_c0 + eps);
    }
    for (a = [45:90:359]) rotate(a) translate([iface_bolt_pcd/2, 0, z_d1 - iface_pilot_depth]) {
      cylinder(d=iface_pilot_d, h=iface_pilot_depth + eps);
      translate([0,0,-iface_pilot_d/2 + eps]) cylinder(d1=0, d2=iface_pilot_d, h=iface_pilot_d/2);
    }
  }
}

// ---------------------------------------------------------------------
//  PART 2b — camera cup adapter (flange bottom at z=0)
// ---------------------------------------------------------------------
module cup_adapter(id=camera_dia, wall=cup_wall_t, h=cup_wall_h) {
  ro = id/2 + wall;
  zt_y = -(ro + 8.75);   // zip-tie tunnel centre
  difference() {
    union() {
      cylinder(d=iface_flange_d, h=flange_t, $fn=fnb);
      cylinder(r=ro, h=h, $fn=fnb);
      translate([-5.5, ro - 1, 0]) cube([11, 7, setscrew_z + 5.5]);
      translate([-7, zt_y - 3.75, 0]) cube([14, 7.5, flange_t + 5.5]);
    }
    translate([0,0,-1]) cylinder(d=id, h=h + 2, $fn=fnb);
    // entry chamfer against elephant's foot
    translate([0,0,-eps]) cylinder(d1=id + 1.2, d2=id, h=0.6, $fn=fnb);
    translate([0, -ro + wall/2, 0]) {
      translate([0,0,h - slot_depth + slot_w/2]) rotate([90,0,0]) cylinder(d=slot_w, h=wall*3, center=true);
      translate([-slot_w/2, -wall*1.5, h - slot_depth + slot_w/2]) cube([slot_w, wall*3, slot_depth]);
    }
    translate([0, ro + 3, setscrew_z]) rotate([90,0,0]) linear_extrude(16, center=true) teardrop2d(1.65);
    translate([-2.9, ro + 1.6, setscrew_z - 3.25]) cube([5.8, 2.7, 20]);
    translate([0, zt_y, 0]) yz_extrude(20) polygon([[-2.1, flange_t], [2.1, flange_t], [2.1, flange_t + 1.6], [0, flange_t + 3.7], [-2.1, flange_t + 1.6]]);
    iface_csk_holes(flange_t);
  }
}

module iface_csk_holes(t)
  for (a = [45:90:359]) rotate(a) translate([iface_bolt_pcd/2, 0, 0]) {
    translate([0,0,-1]) cylinder(d=3.4, h=t + 2);
    translate([0,0,t - 1.4]) cylinder(d1=3.4, d2=6.2, h=1.4 + eps);
  }

module platform_adapter(t=4) difference() {
  cylinder(d=iface_flange_d, h=t, $fn=fnb);
  translate([0,0,-1]) cylinder(d=6.6, h=t + 2);   // 1/4"-20 clearance
  iface_csk_holes(t);
  for (a = [0:60:359]) rotate(a) translate([25, 0, -1]) cylinder(d=2.6, h=t + 2);
}

// ---------------------------------------------------------------------
//  Hardware envelopes
// ---------------------------------------------------------------------
module motor_28byj() translate([motor_c[0], motor_c[1], z_can_bot]) {
  cylinder(d=can_d, h=can_h);
  translate([0,0,can_h - ear_t]) difference() {
    hull() for (s=[-1,1]) translate([0, s*ear_spacing/2, 0]) cylinder(d=7, h=ear_t);
    for (s=[-1,1]) translate([0, s*ear_spacing/2, -1]) cylinder(d=ear_hole, h=3);
  }
  translate([-17, -wirebox[1]/2, 0]) cube(wirebox);
  translate([shaft_off, 0, can_h]) cylinder(d=shaft_boss_d, h=shaft_boss_h);
  translate([shaft_off, 0, can_h]) cylinder(d=shaft_d, h=shaft_boss_h + 9.5);
}
module pinion() translate([center_dist, 0, z_pin0]) rotate(rotor_angle*ring_teeth/pinion_teeth)
  difference() {
    linear_extrude(pinion_face) polygon(gear_pts(pinion_teeth, gear_module, pressure_angle, gear_module, 1.25*gear_module));
    translate([0,0,-1]) intersection() { cylinder(d=shaft_d, h=pinion_face + 2); cube([3, 6, 2*pinion_face], center=true); }
  }
// printable 14T pinion (flat on the bed, 0.3 mm chamfer on the bed side against elephant's foot)
module pinion_print() difference() {
  linear_extrude(pinion_face) polygon(gear_pts(pinion_teeth, gear_module, pressure_angle, gear_module, 1.25*gear_module));
  translate([0,0,-1]) intersection() { cylinder(d=pinion_bore_d, h=pinion_face + 2); cube([pinion_bore_flats, 10, 2*pinion_face + 4], center=true); }
  translate([0,0,-eps]) cylinder(d1=pinion_bore_d + 0.6, d2=pinion_bore_d, h=0.3);
}
module uln2003() {
  translate([uln_pos[0] - uln_board[0]/2, uln_pos[1] - uln_board[1]/2, uln_z0]) cube([uln_board[0], uln_board[1], uln_height]);
  // input header + dupont plugs + wire bend, on the edge facing the centre
  translate([uln_pos[0] + uln_board[0]/2 - uln_hdr_box[0] - 0.5, -uln_hdr_box[1]/2, uln_z0]) cube([uln_hdr_box[0], uln_hdr_box[1], 1.6 + esp_hdr_spacer + dupont_len + uln_wire_bend]);
}
// ESP32 with header rows, dupont plugs and wire bend below
module esp32() {
  translate([-esp_board[0]/2, esp_front_y, esp_pcb_z0]) cube([esp_board[0], esp_board[1], esp_pcb_t]);
  translate([-esp_board[0]/2 + 1.5, esp_front_y + 1.5, esp_pcb_z1]) cube([esp_board[0] - 3, esp_board[1] - 3, esp_comp_h]);
  translate([-4.47, esp_front_y - esp_usb_overhang, esp_pcb_z1]) cube([8.94, esp_usb_len, esp_usb_h]);
  for (s = [-1, 1]) translate([s*esp_row_x - 1.3, esp_front_y + 1.4, floor_t + 0.5]) cube([2.6, esp_board[1] - 2.8, esp_pcb_z0 - floor_t - 0.5]);
}
module camera() translate([0,0,z_d1]) cylinder(d=48, h=107.5);

// ---------------------------------------------------------------------
//  Scenes
// ---------------------------------------------------------------------
ex = exploded_view ? explode_dist : 0;
module cutter(k) {
  if (k == "xz") translate([-100, -200, -10]) cube([200, 200, 200]);
  if (k == "yz") translate([-200, -100, -10]) cube([200, 200, 200]);
}
module scene(cut=undef) {
  module c(col, a=1) color(col, a) if (is_undef(cut)) children(); else intersection() { cutter(cut); children(); }
  c("lightgray") base_housing();
  if (show_hardware) {
    c("steelblue") motor_28byj();
    c("orange") pinion();
    c("green") translate([uln_pos[0] - uln_board[0]/2, uln_pos[1] - uln_board[1]/2, uln_z0]) cube([uln_board[0], uln_board[1], 1.6]);
    c("palegreen", 0.6) translate([uln_pos[0] - uln_board[0]/2, uln_pos[1] - uln_board[1]/2, uln_z0 + 1.6]) cube([uln_board[0], uln_board[1], uln_height - 1.6]);
    c("black") translate([uln_pos[0] + uln_board[0]/2 - uln_hdr_box[0] - 0.5, -uln_hdr_box[1]/2, uln_z0 + 1.6 + esp_hdr_spacer]) cube([uln_hdr_box[0], uln_hdr_box[1], dupont_len]);
    c("dimgray") translate([-esp_board[0]/2, esp_front_y, esp_pcb_z0]) cube([esp_board[0], esp_board[1], esp_pcb_t]);
    c("silver") translate([-4.47, esp_front_y - esp_usb_overhang, esp_pcb_z1]) cube([8.94, esp_usb_len, esp_usb_h]);
    for (s = [-1, 1]) {
      c("gold") translate([s*esp_row_x - 1.3, esp_front_y + 1.4, esp_pcb_z0 - esp_hdr_spacer]) cube([2.6, esp_board[1] - 2.8, esp_hdr_spacer]);
      c("black") translate([s*esp_row_x - 1.3, esp_front_y + 1.4, esp_pcb_z0 - esp_hdr_spacer - dupont_len]) cube([2.6, esp_board[1] - 2.8, dupont_len]);
    }
  }
  translate([0,0,ex]) rotate(rotor_angle) {
    c("royalblue") rotor();
    translate([0,0,z_d1 + ex]) c("tomato") cup_adapter();
    if (show_hardware && show_camera && is_undef(cut)) translate([0,0,2*ex]) color("black", 0.25) camera();
  }
}

module rotating_cup_plate() {
  translate([0,0,z_d1]) mirror([0,0,1]) rotor();
  translate([R_deck + iface_flange_d/2 + 8, 0, 0]) cup_adapter();
}
// parts fixed in the base (lifted 0.01 where they rest on it by design)
module static_hw() { translate([0,0,0.01]) motor_28byj(); pinion(); translate([0,0,0.01]) uln2003(); translate([0,0,0.01]) esp32(); }

if (part == "assembly") scene();
else if (part == "section_xz") scene("xz");
else if (part == "section_yz") scene("yz");
else if (part == "base_housing") base_housing();
else if (part == "rotating_cup") rotating_cup_plate();
else if (part == "rotor") translate([0,0,z_d1]) mirror([0,0,1]) rotor();
else if (part == "cup_adapter") cup_adapter();
else if (part == "platform_adapter") platform_adapter();
else if (part == "pinion") pinion_print();
// rotor lifted 0.01 so the intended sliding contact on the ledge isn't counted
else if (part == "check_rotor_static") intersection() { union() { base_housing(); translate([0,0,-0.01]) { motor_28byj(); uln2003(); esp32(); } } translate([0,0,0.01]) rotate(rotor_angle) rotor(); }
else if (part == "check_gear_mesh") intersection() { pinion(); rotate(rotor_angle) rotor(); }
// rotor pushed sideways by the full rim clearance, toward the pinion
else if (part == "check_gear_shifted") intersection() { pinion(); translate([-rim_radial_clear, 0, 0]) rotate(rotor_angle) rotor(); }
else if (part == "check_base_parts") intersection() { base_housing(); static_hw(); }
else if (part == "check_cup_rotor") intersection() { rotor(); translate([0,0,z_d1 + 0.01]) cup_adapter(); }
