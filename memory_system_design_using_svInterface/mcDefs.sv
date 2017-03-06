//////////////////////////////////////////////////////////////
// mcDefs.sv - Global definitions for memory controller assignment
// Author:	Roy Kravitz 
// Edited by: Harsh Momaya
// Date:	03-March-2017
//
// Description:
// ------------
// Contains the global typedefs, const, enum, structs, etc. for the memory
// controller assignment 
////////////////////////////////////////////////////////////////
package mcDefs;

parameter	 BUSWIDTH = 16;
parameter	 DATAPAYLOADSIZE = 4;
parameter	 MEMSIZE = 256;
parameter 	 DATAWIDTH = 16;
parameter	 DBUFWIDTH = 64;
//parameter	 ADDRWIDTH = ADDRWIDTH = $clog2(MEMDEPTH);

// page number for the memory controllers
parameter [3:0] MEMPAGE1 = 4'h2;
parameter [3:0] MEMPAGE2 = 4'hF;

typedef struct packed {
	logic		[3:0]	page;
	logic		[11:0]	loc;
} memAddr_t;

typedef struct packed {
	logic InstrType;		//Read- 1 or write- 0
	memAddr_t Addr;
} instr_t;

typedef union packed {
	memAddr_t	PgLoc;
	logic		[15:0]	ma;	
} areg_t;

// For memory_if

typedef enum logic [2:0] { Init      = 3'b001, 
                           Read      = 3'b010,
                           Write     = 3'b100 
                         } state_t;

endpackage