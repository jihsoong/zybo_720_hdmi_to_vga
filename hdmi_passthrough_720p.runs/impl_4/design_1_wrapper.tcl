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

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_param gui.test TreeTableDev
  set_param xicom.use_bs_reader 1
  debug::add_scope template.lib 1
  set_property design_mode GateLvl [current_fileset]
  set_property webtalk.parent_dir /home/marshall/workspace/support/hdmi_passthrough_720p/hdmi_passthrough_720p.cache/wt [current_project]
  set_property parent.project_path /home/marshall/workspace/support/hdmi_passthrough_720p/hdmi_passthrough_720p.xpr [current_project]
  set_property ip_repo_paths {
  /home/marshall/workspace/support/hdmi_passthrough_720p/hdmi_passthrough_720p.cache/ip
  /home/marshall/workspace/ip_repo
} [current_project]
  set_property ip_output_repo /home/marshall/workspace/support/hdmi_passthrough_720p/hdmi_passthrough_720p.cache/ip [current_project]
  add_files -quiet /home/marshall/workspace/support/hdmi_passthrough_720p/hdmi_passthrough_720p.runs/synth_4/design_1_wrapper.dcp
  read_xdc -ref design_1_dvi2rgb_0_0 -cells U0 /home/marshall/workspace/support/hdmi_passthrough_720p/hdmi_passthrough_720p.srcs/sources_1/ipshared/digilentinc.com/dvi2rgb_v1_4/4f0fd262/src/dvi2rgb.xdc
  set_property processing_order EARLY [get_files /home/marshall/workspace/support/hdmi_passthrough_720p/hdmi_passthrough_720p.srcs/sources_1/ipshared/digilentinc.com/dvi2rgb_v1_4/4f0fd262/src/dvi2rgb.xdc]
  read_xdc -prop_thru_buffers -ref design_1_clk_wiz_0_0 -cells inst /home/marshall/workspace/support/hdmi_passthrough_720p/hdmi_passthrough_720p.srcs/sources_1/bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0_board.xdc
  set_property processing_order EARLY [get_files /home/marshall/workspace/support/hdmi_passthrough_720p/hdmi_passthrough_720p.srcs/sources_1/bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0_board.xdc]
  read_xdc -ref design_1_clk_wiz_0_0 -cells inst /home/marshall/workspace/support/hdmi_passthrough_720p/hdmi_passthrough_720p.srcs/sources_1/bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0.xdc
  set_property processing_order EARLY [get_files /home/marshall/workspace/support/hdmi_passthrough_720p/hdmi_passthrough_720p.srcs/sources_1/bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0.xdc]
  read_xdc /home/marshall/Downloads/ZYBO_Master.xdc
  link_design -top design_1_wrapper -part xc7z010clg400-1
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  catch {write_debug_probes -quiet -force debug_nets}
  opt_design 
  write_checkpoint -force design_1_wrapper_opt.dcp
  catch {report_drc -file design_1_wrapper_drc_opted.rpt}
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  place_design 
  write_checkpoint -force design_1_wrapper_placed.dcp
  catch { report_io -file design_1_wrapper_io_placed.rpt }
  catch { report_clock_utilization -file design_1_wrapper_clock_utilization_placed.rpt }
  catch { report_utilization -file design_1_wrapper_utilization_placed.rpt -pb design_1_wrapper_utilization_placed.pb }
  catch { report_control_sets -verbose -file design_1_wrapper_control_sets_placed.rpt }
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force design_1_wrapper_routed.dcp
  catch { report_drc -file design_1_wrapper_drc_routed.rpt -pb design_1_wrapper_drc_routed.pb }
  catch { report_timing_summary -warn_on_violation -max_paths 10 -file design_1_wrapper_timing_summary_routed.rpt -rpx design_1_wrapper_timing_summary_routed.rpx }
  catch { report_power -file design_1_wrapper_power_routed.rpt -pb design_1_wrapper_power_summary_routed.pb }
  catch { report_route_status -file design_1_wrapper_route_status.rpt -pb design_1_wrapper_route_status.pb }
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
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

