vlib work
vlog projectTop.v datapath.v control.v car_sprite_atlas.v trackRam.v DelayCounter.v
vsim -L altera_mf_ver projectTop
log {/*}
add wave -r {/*}

force {Clock} 0 0ns, 1 {1ns} -r 2ns

force {Start} 0
force {simReset} 1
force {Resetn} 0
run 4ns

force {simReset} 0
force {Resetn} 1
run 155660ns

force {Start} 1
force {moveForward} 0
force {moveLeft} 0
force {moveRight} 0
run 1000100ns