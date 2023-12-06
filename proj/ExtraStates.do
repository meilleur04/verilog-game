vlib work
vlog projectTop.v datapath.v control.v car_sprite_atlas.v winScreenRam.v
vlog trackRam.v boomRam.v startScreenRam.v DelayCounter.v SecondsCounter.v
vsim -L altera_mf_ver projectTop
log {/*}
add wave -r {/*}

force {Clock} 0 0ns, 1 {1ns} -r 2ns

force {simReset} 1
force {Resetn} 0
force {Start} 0
run 4ns

force {simReset} 0
force {Resetn} 1
force {Start} 0
run 311320ns

force {moveForward} 0
force {moveLeft} 0
force {moveRight} 0
force {Start} 1
run 4ns

# Now testing move, moveForward, moveRight, moveLeft

force {Resetn} 1
force {moveForward} 1
force {moveLeft} 0
force {moveRight} 0 
force {Start} 1
run 5000ns