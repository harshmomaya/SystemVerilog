//////////////////////////////////////////////////////////////////////////////////
// top_module.sv : Integrates all the components 
// Author : Harsh Momaya
// ECE 571  ||  Portland State University
// Date: 03-March-2017
// Description:
//  •	This module connects all the interface and module units 
//  •	Module/interface instances are used to connect the blocks and CPU is the 
//      main module from where instruction is provided to the design
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

import mcDefs::*;

module top_module(input logic clk, resetH,
		  instr_t Instr,
		  input logic [63:0] datain,
		  output logic [63:0] dataout 
);


main_bus_if mbus(clk, resetH);

memArray_if MArray();

// Two memory_if instances as per the design requirement
memory_if #(MEMPAGE1) memIF (mbus.slave, MArray.MemIF);
memory_if #(MEMPAGE2) MemIF2(mbus.slave, MArray.MemIF);

mem memory(mbus, MArray.Mem);

processor_if procIF (mbus.master);

cpu main(procIF.SndRcv, Instr, mbus, datain, dataout);
	
endmodule
