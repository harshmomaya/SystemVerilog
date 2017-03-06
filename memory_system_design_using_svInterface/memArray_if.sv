//////////////////////////////////////////////////////////////
// memArray_if.sv - memory Array interface
//
// Author:	Roy Kravitz 
// Date:	03-March-2017
// Edited by: Harsh Momaya
// Description:
// ------------
// Defines the interface between the memory interface (the memory controller)
// and the memory array.  This interface only contains wires.  The memory
// array control is done by the memory interface
// Note:  Original concept by Don T. but the implementation is my own
//////////////////////////////////////////////////////////////////////

// global definitions, parameters, etc.
import mcDefs::*;
	
interface memArray_if #(parameter ADDRWIDTH = 12)();


// memory interface signals

// these signals are tristate because they may be driven by more than one 
// memory interface
tri		[ADDRWIDTH-1:0]		Addr;		// memory address
tri		[BUSWIDTH-1:0]		DataIn;		// Data to be written to the array
tri							rdEn;		// Asserted high to perfrom a memory read
tri							wrEn;		// Asserted high to perform a memory write

// This signal does not need to be tristate because there is (in this implementation)
// a single shared memory array
logic	[BUSWIDTH-1:0]		DataOut;

modport MemIF          // used by memory_if unit 
(
	output		Addr,
	output		DataIn,
	output		rdEn,
	output		wrEn,
	input		DataOut
);

modport Mem             // Added by Harsh Momaya for memory unit
(
    input Addr,DataIn, rdEn, wrEn,
    output DataOut
);

endinterface: memArray_if