proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
set_msg_config -id {Synth 8-256} -limit 10000
set_msg_config -id {Synth 8-638} -limit 10000
set_msg_config  -id {IP_Flow 19-1663}  -string {{CRITICAL WARNING: [IP_Flow 19-1663] Duplicate IP found for 'DigilentInc:user:Digi_LED:1.0'. The one found in IP location '/home/marshall/workspace/ip_repo/Digi_LED_1.0' will take precedence over the same IP in location /home/marshall/workspace/ip_repo/edit_Digi_LED_v1_0.srcs/sources_1/imports/Digi_LED_1.0}}  -suppress 

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  set_param gui.test TreeTableDev
  set_param xicom.use_bs_reader 1
  debug::add_scope template.lib 1
  open_checkpoint design_1_wrapper_routed.dcp
  set_property webtalk.parent_dir /home/marshall/workspace/support/hdmi_passthrough_720p/hdmi_passthrough_720p.cache/wt [current_project]
  write_bitstream -force design_1_wrapper.bit 
  if { [file exists /home/marshall/workspace/support/hdmi_passthrough_720p/hdmi_passthrough_720p.runs/synth_4/design_1_wrapper.hwdef] } {
    catch { write_sysdef -hwdef /home/marshall/workspace/support/hdmi_passthrough_720p/hdmi_passthrough_720p.runs/synth_4/design_1_wrapper.hwdef -bitfile design_1_wrapper.bit -meminfo design_1_wrapper.mmi -file design_1_wrapper.sysdef }
  }
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

