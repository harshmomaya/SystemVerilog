//////////////////////////////////////////////////////////////
// mem.sv - Memory simulator for ECE 571 HW #4
//
// Author:	Roy Kravitz 
// Date:	24-Feb-2017
//
// Description:
// ------------
// Implements a simple synchronous Read/Write memory system.  The model is parameterized
// to adjust the width and depth of the memory array
//
// Modified from HW #3 to make use of interfaces and to better support a shared
// memory model (i.e. Two instances of memory controller interface)
// 
// This version of the memory array uses an associative array and has a depth of
// 64K to cover the entire address space of the assignment.  I used an associative
// array because large memories are generally sparsely populated.  I made the index
// of type int because in this case I did want to change X and Z to 0 because there
// are cycles where the memory is performing a read but the address isn't being driven.
// The read data from those cases isn't returned.  No harm, no foul.
//
// Original version created by Don T. but the modifications are mine
////////////////////////////////////////////////////////////////

// global definitions, parameters, etc.
import mcDefs::*;

module mem
#(
	parameter MEMDEPTH = 2**16
)
(
	main_bus_if							MBUS,	// Main bus interface 
												// you get the clock/reset from here
	memArray_if.Mem						MIF		// memory array interface
												// you get the memory address, data and control from here
);


// parameter BUSWIDTH is provided in mcDefs.sv
localparam ADDRWIDTH = $clog2(MEMDEPTH);	// number of address bits for the array

// declare internal variables
logic	[BUSWIDTH-1:0]		M[int];			// memory array implemented as an Associative array
											// because accesses may be sparse 

// read a location from memory.  We need to check rdEn
// to make sure it's asserted because it could be 1'z
// 1'z will result in x because we used == for the compare
// and x is considered false in SystemVerilog.  We also check
// to see if the memory location has been written.  If not, we
// return Zs.
always_comb begin
	if (M.exists(MIF.Addr) & (MIF.rdEn == 1'b1)) begin
		MIF.DataOut = M[int'(MIF.Addr)];
	end
	else begin
		MIF.DataOut = 'z;
	end
end

// write a location in memory
// We need to check wrEn to make sure it's asserted
// because it could be 1'z 
always @(posedge MBUS.clk) begin
	if (MIF.wrEn == 1'b1) begin
		// delete the existing entry and create it anew
		M.delete(int'(MIF.Addr));
		M[int'(MIF.Addr)] = MIF.DataIn;
	end
end // write a location in memory

endmodule
