onerror {resume}
add list -width 15 /top_tb/clock
add list /top_tb/key_1
add list /top_tb/key_2
add list /top_tb/key_3
add list /top_tb/enable
add list /top_tb/SW_in
add list /top_tb/reset
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta collapse
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
