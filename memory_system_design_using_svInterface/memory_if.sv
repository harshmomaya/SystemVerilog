/////////////////////////////////////////////////////////////////////////////////////////////
// memory_if.sv : Interface between main bus and memory unit
// ECE 571  ||  Portland State University
// Author : Harsh Momaya
// Date: 03-March-2017 
// Description: 
//      The following interface instantiates the slave modport from main_bus_if interface.
//      This interface checks if the PAGE number is valid. 
//      If the PAGE is invalid then the write/read operation is not performed on the memory. 
// 
/////////////////////////////////////////////////////////////////////////////////////////////

import mcDefs::*;

interface memory_if #(parameter logic [3:0] PAGE = MEMPAGE1)(	
	main_bus_if.slave S, // interface to memory is a slave
	memArray_if.MemIF A // interface to memory array
);
  
   
   // tri [15:0] _AddrData,
	logic [11:0] addr = '0, baddr = '0;
	logic rdEn, wrEn;
	
	// This variable is use to store data obtained from AddrData during Write state 
	logic [DATAWIDTH-1:0]                 data;                                  
	state_t                         nextState, state= Init;           // state variables  	
	logic [($clog2(DATAPAYLOADSIZE)):0]   count;                      // Based on data burst	

    ///////////////////////////////////////////////////////////////////////////
    //  State transition
    ///////////////////////////////////////////////////////////////////////////
    
    always_ff @(posedge S.clk)
        begin
            if (S.resetH == 1'b1) begin
                state <= Init;
                addr  <= '0;
                end
            else  begin
                state <= nextState;
                addr <= baddr;
                end    
        end
     
     /////////////////////////////////////////////////////////////////////////
     //  Next State    
     /////////////////////////////////////////////////////////////////////////
     
     always_comb
        begin
            //state = Init;
            unique case(state)
                Init: begin
                        if (S.AddrValid && S.AddrData[15:12] == PAGE) begin         // PAGE logic and S.AddrValid check
                            baddr = S.AddrData;
                            if (S.rw)  nextState = Read;
                            else     nextState = Write; 
                            end
                        else begin
                            nextState = Init;
                            baddr = baddr;
                            end
                      end
                      
                 Read: begin
                          baddr = addr;
                          baddr = baddr + 1'b1;
                         if(count > 1) nextState = Read;
                         else nextState = Init;
                       end
                       
                 Write: begin
                            baddr = addr;
                            baddr = baddr + 1'b1;
                            if(count > 1) nextState = Write;
                            else nextState = Init;      
                        end
            endcase                    
        end 
     
    /////////////////////////////////////////////////////////////////////////
    // Output logic 
    //////////////////////////////////////////////////////////////////////////
    
    always_comb
            begin
                //state = Init;
                unique case(state)                      // Only 3 states possible
                    Init: begin
                            data = '0;
                            rdEn = 1'bz;
                            wrEn = 1'bz;
                          end
                          
                     Read: begin
                             data = '0;
                             wrEn = 1'b0;
                             if(count > 0) rdEn = 1'b1;
                             else rdEn = 1'b0;
                           end
                           
                     Write: begin
                                rdEn = 1'b0;
                                if(count > 0) begin
                                    wrEn = 1'b1;
                                    data = S.AddrData;               // Lock the data to be written
                                end
                                else begin
                                    data = 'b0;
                                    wrEn = 1'b0;
                                end        
                            end
                endcase                    
            end     
    
    /////////////////////////////////////////////////////////////////////////////////
    //  Address logic
    //  AddressValid is aynschronous hence its in the sensitivity list.
    /////////////////////////////////////////////////////////////////////////////////
           
//    always_ff @(posedge S.clk, posedge S.AddrValid)
//        begin
//            if (S.resetH) addr <= 'b0;
//            else if (state == Init && S.AddrValid && S.AddrData[15:12] == PAGE) addr <= S.AddrData[(BUSWIDTH-1):0];     // Lock the Address
//            else if ((rdEn || wrEn) && ~S.AddrValid) addr <= addr + 1'b1;            
//            else addr <= addr;
//        end                                    

     ////////////////////////////////////////////////////////////////////////////////        
     // Counter logic. This counter controls the next state and output logic of FSM 
     // AddressValid is aynschronous hence its in the sensitivity list. 
     /////////////////////////////////////////////////////////////////////////////// 
             
     always_ff @(posedge S.clk, posedge S.AddrValid)
        begin
            if(S.resetH) count <= 0;
            else if (S.AddrValid && (state == Init)) count <= DATAPAYLOADSIZE;
            else if ((rdEn || wrEn) && ~S.AddrValid) count <= count - 1'b1;
            else count <= count;
        end
     
     ////////////////////////////////////////////////////////////////////////////////
     // Tri state logic
     ////////////////////////////////////////////////////////////////////////////////
      
     assign A.rdEn = rdEn;
     assign A.wrEn = wrEn;
     assign A.Addr = ((state == Init && S.AddrValid && S.AddrData[15:12] == PAGE) || (state == Read || state == Write))? addr: 'z; 
     assign S.AddrData = (state == Read)? A.DataOut:({DATAWIDTH{1'bz}});
     // for write
     assign A.DataIn  = (state == Write) ? data : 'bz; 

endinterface: memory_if