set_global_assignment -entity "SDCLK" -library "lib_SDCLK" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "SDCLK" -library "lib_SDCLK" -name IP_TOOL_VERSION "17.0"
set_global_assignment -entity "SDCLK" -library "lib_SDCLK" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_SDCLK" -name SPD_FILE [file join $::quartus(sip_path) "SDCLK.spd"]

set_global_assignment -library "lib_SDCLK" -name MISC_FILE [file join $::quartus(sip_path) "SDCLK_sim/SDCLK.vo"]
