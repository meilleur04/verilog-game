vlib work
vlog datapath.v car_sprite_atlas.v trackRam.v
vsim -L altera_mf_ver datapath

log {/*}
add wave {/*}

force {Clock} 0 0ns, 1 {1ns} -r 2ns

force {Resetn} 1
force {draw_background} 1
force {draw_car} 0
run 153600ns

force {Resetn} 1
force {draw_background} 0
force {draw_car} 1
run 2060ns