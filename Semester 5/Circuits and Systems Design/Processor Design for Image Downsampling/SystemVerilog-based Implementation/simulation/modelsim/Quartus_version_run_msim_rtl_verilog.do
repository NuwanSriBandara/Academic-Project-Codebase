transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/SystemVerilog/processor_design_verilog_latest/processor_design_verilog/processor_design_verilog.srcs/sources_1/new {D:/SystemVerilog/processor_design_verilog_latest/processor_design_verilog/processor_design_verilog.srcs/sources_1/new/ALU.v}

