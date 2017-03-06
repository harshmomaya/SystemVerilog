////////////////////////////////////////////////////////////////////////
// main_bus_if.sv - Main Bus interface for memory controller
//
// Author:	Roy Kravitz 
// Date:	23-Feb-2017
//
// Description:
// ------------
// Defines the interface between the processor interface (a master) and
// the memory interface (a slave).  Bus is based on the processor/memory
// bus used in HW #3
// 
// Note:  Original concept by Don T. but the implementation is my own
//////////////////////////////////////////////////////////////////////

// global definitions, parameters, etc.
import mcDefs::*;
	
interface main_bus_if
(
	input logic clk,
	input logic resetH
);
	
	// bus signals
	tri		[BUSWIDTH-1: 0]		AddrData;
	logic					AddrValid = 1'b0;
	logic					rw = 1'b0;
	
	initial 
	   $display("Entered main bus. Main bus-> Memory_if");
	
	modport master (
		input	clk,
		input	resetH,
		output	AddrValid,
		output	rw,
		inout	AddrData
	);
	
	modport slave (
		input	clk,
		input	resetH,
		input	AddrValid,
		input	rw,
		inout	AddrData
	);
	
	
endinterface: main_bus_if