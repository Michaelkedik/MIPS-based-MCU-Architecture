onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/clock
add wave -noupdate /top_tb/key_1
add wave -noupdate /top_tb/key_2
add wave -noupdate /top_tb/key_3
add wave -noupdate /top_tb/enable
add wave -noupdate /top_tb/SW_in
add wave -noupdate /top_tb/reset
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 500000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {99999999050 ps} {100000000050 ps}
