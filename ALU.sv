/**
* ALU.sv - arithmetic logic unit for stack based CPU
*
* @author: Jeremiah Vandagrift (jcv3@pdx.edu, https://github.com/jvandag)
* @date: 11-Nov-2024
*
* @brief
* takes in two operands and performs a an operation on them based on the passed in 
* opcode. Pushes the result to the result output if there is no error
*/

import stackCPU_DEFS::*;

logic log = 1;

module alu_signed (
    input logic signed [DATA_WIDTH_DEF-1:0] operand1,
    input logic signed [DATA_WIDTH_DEF-1:0] operand2,
    input opcode_t                          opcode,
    output logic signed [DATA_WIDTH_DEF-1:0] result,
    output logic                             error
);
    always_comb begin
        error = 0;
        result = 0;
        case (opcode)
			PUSH_IMMEDIATE: result = result;
            ADD: begin
				result = operand1 + operand2;
				if (log) begin
					$display("Time: %0t | Opcode: %0d | Operand1: %0d | Operand2: %0d | Result: %0d | Error: %0b",
                     $time, opcode, operand1, operand2, result, error);
				end
			end
            SUB: begin
				result = operand1 - operand2;
				if (log) begin
					$display("Time: %0t | Opcode: %0d | Operand1: %0d | Operand2: %0d | Result: %0d | Error: %0b",
                     $time, opcode, operand1, operand2, result, error);
				end
			end
            MUL: begin
				result = operand1 * operand2;
				if (log) begin
					$display("Time: %0t | Opcode: %0d | Operand1: %0d | Operand2: %0d | Result: %0d | Error: %0b",
                     $time, opcode, operand1, operand2, result, error);
				end
			end
            DIV: begin
                if (operand2 == 0) begin
                    error = 1;
					$display("Time: %0t ERROR[ALU] Operand 1 == 0.", $time);
                end else begin
                    result = operand1 / operand2;
					if (log) begin
						$display("Time: %0t | Opcode: %0d | Operand1: %0d | Operand2: %0d | Result: %0d | Error: %0b",
						 $time, opcode, operand1, operand2, result, error);
					end

                end
            end
            MOD: begin
                if (operand2 == 0) begin
                    error = 1;
					$display("Time: %0t ERROR[ALU] Operand 2 == 0.", $time);
                end else begin
                    result = operand1 % operand2;
					if (log) begin
						$display("Time: %0t | Opcode: %0d | Operand1: %0d | Operand2: %0d | Result: %0d | Error: %0b",
						 $time, opcode, operand1, operand2, result, error);
					end

                end
            end
            AND: begin
				result = operand1 & operand2;
				if (log) begin
					$display("Time: %0t | Opcode: %0d | Operand1: %0d | Operand2: %0d | Result: %0d | Error: %0b",
                     $time, opcode, operand1, operand2, result, error);
				end

			end
            OR: begin
				result = operand1 | operand2;
				if (log) begin
					$display("Time: %0t | Opcode: %0d | Operand1: %0d | Operand2: %0d | Result: %0d | Error: %0b",
                     $time, opcode, operand1, operand2, result, error);
				end

			end
            INVERT: begin
				result = ~operand2;//~operand1-1'b1; //signed(~operand1);
				if (log) begin
					$display("Time: %0t | Opcode: %0d | Operand1: %0d | Operand2: %0d | Result: %0d | Error: %0b",
                     $time, opcode, operand1, operand2, result, error);
				end

			end
            default: begin
				error = 1;
				$display("Time: %0t Invallid opcode in ALU: %b", $time, opcode);
			end
        endcase
    end
endmodule: alu_signed
