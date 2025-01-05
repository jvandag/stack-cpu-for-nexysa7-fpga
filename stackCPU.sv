/**
* stackCPU.sv - stack based CPU
*
* @author: Jeremiah Vandagrift (jcv3@pdx.edu, https://github.com/jvandag)
* @date: 11-Nov-2024
* @version 1.1.0
*
* @brief
* Uses an FSM-D to direct data from instructions to the stack and from the stack
* to the ALU when recieving an operation opcode
*/


import stackCPU_DEFS::*;

module stackCPU #(
	parameter int DATA_WIDTH = DATA_WIDTH_DEF,
	parameter int STACK_DEPTH = STACK_DEPTH_DEF,
	parameter int INSTR_WIDTH = INSTR_WIDTH_DEF,
	parameter int PC_WIDTH = PC_WIDTH_DEF
) (
	input logic	clk,
	input logic resetn,
	input logic [INSTR_WIDTH-1:0] instruction,
	input logic single_step,
	output logic [INSTR_WIDTH-1:0] pc,
	output logic signed [DATA_WIDTH-1:0] result,
	output logic valid_result,
	output logic error,
	output logic halt
	
);
    // Assign reset to the invert of the inverted reset signal
    assign reset = ~resetn;
	// FSM States
	typedef enum logic [3:0] {
		IDLE,
		POP_FIRST,
		POP_SECOND,
		EXECUTE,
		PUSH_IMM,
		PUSHING,
		INC_PC,
		HALT,
		ERROR
	} state_t;
	
	state_t current_state, next_state;
	
	opcode_t opcode; // Command Operation Code
	logic signed [DATA_WIDTH-1:0] op1, op2, alu_result, imm_value, stack_top;
	logic alu_err, push, pop, empty, full, load_imm, one_or_more, two_or_more;
	
	
	// Instantiate the stack used by the CPU
	Stack #(
		.DATA_WIDTH(DATA_WIDTH),
		.DEPTH(STACK_DEPTH)
	) op_stack (
		.clk(clk),
		.reset(reset),
		.push(push),
        .pop(pop),
        .data_in(load_imm ? imm_value : alu_result),
        .data_out(stack_top),
        .full(full),
        .empty(empty),
        .one_or_more(one_or_more),
        .two_or_more(two_or_more)
	);
	
	// Instantiate the ALU
	alu_signed alu (
		.operand1(op1),
		.operand2(op2),
		.opcode(opcode),
		.result(alu_result),
		.error(alu_err)
	);
	
    // Main sequential block
	always_ff @(posedge clk or posedge reset) begin
	    // If the reset button is pressed
		if (reset) begin
			op1 <= 0;
			op2 <= 0;
			current_state = IDLE;
			pc <= 0;
		end
		else begin // state and program advancement
		//always advance to next state unless at the end of the instruction cycle
			if (current_state != INC_PC) begin
			     current_state <= next_state;
			end
			// If single step is recieved process the next instruction 
			else if (current_state == INC_PC && single_step) begin
			     pc <= pc + 1;
			     current_state <= IDLE;
			end
			case (current_state) // latch the operands unless we're in their specified state to reassign their value
				POP_FIRST: op2 <= stack_top; 
				POP_SECOND: op1 <= stack_top;
				default: begin
					op1 <= op1;
					op2 <= op2;
				end
			endcase
		end
	end

	always_comb begin
		// set defaults
		push			= 0;
        pop				= 0;
        load_imm		= 0;
        halt			= 0;
        error			= 0;
        result 			= 0;
		valid_result    = 0;
		
		case(current_state)
			IDLE: begin
				//check for new opcode and command value
				opcode = opcode_t'(instruction[INSTR_WIDTH-1:INSTR_WIDTH-5]);
				imm_value = {{(DATA_WIDTH-10){instruction[9]}}, instruction[9:0]};

				case (opcode)
					PUSH_IMMEDIATE: begin
						if (!full) begin
							load_imm = 1; //load the immedate value in the push command to the stacks data_in
							result = imm_value; // set result to the value in the push command to display it on the 7segs
							push = 1; // push result to stack on next clock cycle
							valid_result = 1; // tell the exterior model to update the displays with the result
							next_state = INC_PC; // prepare to process the next instruction
						end
						else begin
							error = 1;
							next_state = ERROR;
						end
					end
					INVERT: begin
						if (one_or_more) begin //check that there is at least one item on the stack
                            next_state = POP_FIRST;
                        end 
						else begin
							error = 1;
                            next_state = ERROR;
                        end						
					end
					HALT_CPU: begin
                        halt = 1;
                        next_state = HALT;
					end
					default: begin
					    /* if we're not doing a unary operation (only invert for this CPU)
					    then we need at least two items on the stack to fill our operands
					    */
						if (two_or_more) begin
							next_state = POP_FIRST;
						end
						else begin
							error = 1;
							next_state = ERROR;
						end
					end
				endcase
			end
			POP_FIRST: begin
			    // latch top of stack to first operand
				if (opcode == INVERT) begin
				// if inverting exicute after gathering the top of the stack value for the the first operand
					next_state = EXECUTE;
					pop = 1; // pop the stack
				end
				else begin //else retrieve a value for the second
					pop = 1;
					next_state = POP_SECOND;
				end
			end
			POP_SECOND: begin
			// latch the top of stack value to the second operand and proceed to the execution
				pop = 1; // pop the stack
				next_state = EXECUTE;
			end
			EXECUTE: begin
                if (alu_err) begin //check if the ALU result is valid
                    next_state = ERROR;
                end else begin
                    // push the result to the top of stack
                    push = 1;
                    result = alu_result;
                    
                    // tell the exterior model to update the displays with the result
                    valid_result = 1;
                    
                    // prepare for the next instruction
                    next_state = INC_PC;
                end
			end
			INC_PC: begin 
                /* Wait for single_step to be pressed and next
                state will be changed in separate block */
			end
			HALT: begin //stop the program and continuously display halt state
                halt = 1;
                next_state = HALT;
            end
			ERROR: begin //stop the program and continuously stay in error state
				error = 1;
				next_state = ERROR;
			end
			default: begin // If the state is not an expected state then error, we shouldn't get here under normal conditions
				next_state = ERROR;
				error = 1;
			end
		endcase
	end

endmodule: stackCPU