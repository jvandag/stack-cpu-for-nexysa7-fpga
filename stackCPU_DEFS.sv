/**
 * @file stackCPU_DEFs.sv
 * @version 1.0.0
 * @author	Roy Kravitz (roy.kravitz@pdx.edu)
 * @date	16-Nov-2024
 *
 * @detail
 * Package that contains the definitions and constants that are common
 * in the stack CPU.
 *
 * Revision History
 * ----------------
 * 1.0.0	(16-Nov-2024)	Initial version
 *
 */
 package stackCPU_DEFS;
 // depth and width parameters
localparam DATA_WIDTH_DEF = 32;			// datapath is 32-bits wide
localparam STACK_DEPTH_DEF = 16;		// depth of the operand stack
localparam INSTR_WIDTH_DEF = 16;		// width of an instruction 
localparam PGRM_MEM_DEPTH_DEF = 256;	// number of instructions in program memory
localparam PC_WIDTH_DEF = $clog2(PGRM_MEM_DEPTH_DEF);	//number of addr bits PC
 
 // opcodes
 typedef enum logic [4:0] {
        PUSH_IMMEDIATE = 5'b00000,
        ADD            = 5'b00001,
        SUB            = 5'b00010,
        MUL            = 5'b00011,
        DIV            = 5'b00100,
        MOD            = 5'b00101,
        AND            = 5'b00110,  // Bitwise AND (top two stack elements)
        OR             = 5'b00111,  // Bitwise OR (top two stack elements)
        INVERT         = 5'b01000,  // Bitwise INVERT (single stack element)
	HALT_CPU	   = 5'b11111	// HALT - stops the program until reset is asserted
 } opcode_t;
 
 endpackage: stackCPU_DEFS
 
