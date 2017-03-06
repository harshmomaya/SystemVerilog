//////////////////////////////////////////////////////////////////////////////////
// cpu.sv - Module CPU which calls read or write task based on input instruction
//
// Author:	Roy Kravitz 
// Date:	03-March-2017
// Edited by Harsh Momaya
//
// Description:
// ------------
// This module deals in terms of instruction. The instruction consists of:
//      o InstrType: To differentiate between Read and Write operation.
//      o Addr: It's a 16-bit value which is made up of page and base address
//////////////////////////////////////////////////////////////////////////////////


import mcDefs::*;

module cpu( processor_if.SndRcv RW,
	    	input instr_t instr, 
	    	main_bus_if MainBus, 
		    input logic [63:0] DataIn,
		    output logic [63:0] DataOut = '0
	       );
	

    always_comb begin
        if(MainBus.resetH) DataOut = 'z;
        else if(instr.InstrType == 1'b1) begin		
            // Read instruction
            $display("Cpu-> Read task");
            RW.Proc_rdReq(instr.Addr.page, instr.Addr.loc, DataOut);
        end    
        else if(instr.InstrType == 1'b0) begin	  
            // Write instruction
            $display("Cpu-> Write task");
            DataOut <= 'z;                  // To avoid garbage data on output bus
            RW.Proc_wrReq(instr.Addr.page, instr.Addr.loc, DataIn);
        end
        else begin end      // do nothing
	 end

endmodule
