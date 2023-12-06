vlib work
vlog car_sprite_atlas.v
vsim -L altera_mf_ver car_sprite_atlas

log {/*}
add wave {/*}

force {address} 0000000000001
force {data} 111111
force {wren} 0
force {clock} 0 0ns, 1 {1ns} -r 2ns
run 10ns