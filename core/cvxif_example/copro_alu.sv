// Copyright 2024 Thales DIS France SAS
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
// You may obtain a copy of the License at https://solderpad.org/licenses/
//
// Original Author: Guillaume Chauvon

module copro_alu
  import cvxif_instr_pkg::*;
#(
    parameter int unsigned NrRgprPorts = 2,
    parameter type readregflags_t = logic,
    parameter type hartid_t = logic,
    parameter type id_t = logic,
    parameter type registers_t = logic

) (
    input  logic              clk_i,
    input  logic              rst_ni,
    input  registers_t        registers_i,
    input  readregflags_t     rs_valid_i,
    input  opcode_t           opcode_i,
    input  hartid_t           hartid_i,
    input  id_t               id_i,
    input  logic       [ 4:0] rd_i,
    output logic       [63:0] result_o,     // TODO parametrize to 64 bits
    output hartid_t           hartid_o,
    output id_t               id_o,
    output logic       [ 4:0] rd_o,
    output logic              valid_o,
    output logic              we_o
);

  logic [63:0] result_n, result_q;
  hartid_t hartid_n, hartid_q;
  id_t id_n, id_q;
  logic valid_n, valid_q;
  logic [4:0] rd_n, rd_q;
  logic we_n, we_q;
  logic signed [7:0] sparse[3:0][1:0];
  logic signed [7:0] sparse_n[3:0][1:0];
  logic [1:0] meta_data[3:0][1:0];
  logic [1:0] meta_data_n[3:0][1:0];
  logic signed [7:0] dense[3:0][3:0];
  logic signed [7:0] dense_n[3:0][3:0];
  logic signed [31:0] ACC[3:0][3:0];
  logic signed [31:0] ACC_n[3:0][3:0];

  assign result_o = result_q;
  assign hartid_o = hartid_q;
  assign id_o     = id_q;
  assign valid_o  = valid_q;
  assign rd_o     = rd_q;
  assign we_o     = we_q;

  always_comb begin
    result_n    = '0;
    hartid_n    = hartid_i;
    id_n        = id_i;
    valid_n     = 1'b1;
    rd_n        = rd_i;
    we_n        = '0;
    dense_n     = dense;
    sparse_n    = sparse;
    meta_data_n = meta_data;
    ACC_n       = ACC;
    case (opcode_i)
      cvxif_instr_pkg::RESET_ACC: begin
        ACC_n[0] = {32'b0, 32'b0, 32'b0, 32'b0};
        ACC_n[1] = {32'b0, 32'b0, 32'b0, 32'b0};
        ACC_n[2] = {32'b0, 32'b0, 32'b0, 32'b0};
        ACC_n[3] = {32'b0, 32'b0, 32'b0, 32'b0};
      end
      cvxif_instr_pkg::LOAD_DENSE: begin
        /*dense_n[0][0] = registers_i[0][63:56];
        dense_n[0][1] = registers_i[0][55:48];
        dense_n[0][2] = registers_i[0][47:40];
        dense_n[0][3] = registers_i[0][39:32];
        dense_n[1][0] = registers_i[0][31:24];
        dense_n[1][1] = registers_i[0][23:16];
        dense_n[1][2] = registers_i[0][15:8];
        dense_n[1][3] = registers_i[0][7:0];
        dense_n[2][0] = registers_i[1][63:56];
        dense_n[2][1] = registers_i[1][55:48];
        dense_n[2][2] = registers_i[1][47:40];
        dense_n[2][3] = registers_i[1][39:32];
        dense_n[3][0] = registers_i[1][31:24];
        dense_n[3][1] = registers_i[1][23:16];  
        dense_n[3][2] = registers_i[1][15:8]; 
        dense_n[3][3] = registers_i[1][7:0];*/

        dense_n[0][0] = registers_i[0][7:0];
        dense_n[0][1] = registers_i[0][15:8];
        dense_n[0][2] = registers_i[0][23:16];
        dense_n[0][3] = registers_i[0][31:24];
        dense_n[1][0] = registers_i[0][39:32];
        dense_n[1][1] = registers_i[0][47:40];
        dense_n[1][2] = registers_i[0][55:48];
        dense_n[1][3] = registers_i[0][63:56];
        dense_n[2][0] = registers_i[1][7:0];
        dense_n[2][1] = registers_i[1][15:8];
        dense_n[2][2] = registers_i[1][23:16];
        dense_n[2][3] = registers_i[1][31:24];
        dense_n[3][0] = registers_i[1][39:32];
        dense_n[3][1] = registers_i[1][47:40];  
        dense_n[3][2] = registers_i[1][55:48]; 
        dense_n[3][3] = registers_i[1][63:56];
      end
      cvxif_instr_pkg::LOAD_DENSE_START: begin
        /*Valid results for register_i[0] come after 2 cycles from when the instruction starts execution meaning the rows 2 and 3 of dense_n array are invalid until the register_i[0] becomes valid
        (rs_valid == 0b11) and then and only then do we want the multiplication to take place because it changes the state of the ACC_n and there for in the next cycle the state of 
        ACC with invalid data that are needed in the multiplication process thus producing incorrect results*/
        /*dense_n[0][0] = registers_i[0][63:56];
        dense_n[0][1] = registers_i[0][55:48];
        dense_n[0][2] = registers_i[0][47:40];
        dense_n[0][3] = registers_i[0][39:32];
        dense_n[1][0] = registers_i[0][31:24];
        dense_n[1][1] = registers_i[0][23:16];
        dense_n[1][2] = registers_i[0][15:8];
        dense_n[1][3] = registers_i[0][7:0];
        dense_n[2][0] = registers_i[1][63:56];
        dense_n[2][1] = registers_i[1][55:48];
        dense_n[2][2] = registers_i[1][47:40];
        dense_n[2][3] = registers_i[1][39:32];
        dense_n[3][0] = registers_i[1][31:24];
        dense_n[3][1] = registers_i[1][23:16];  
        dense_n[3][2] = registers_i[1][15:8]; 
        dense_n[3][3] = registers_i[1][7:0];*/

        dense_n[0][0] = registers_i[0][7:0];
        dense_n[0][1] = registers_i[0][15:8];
        dense_n[0][2] = registers_i[0][23:16];
        dense_n[0][3] = registers_i[0][31:24];
        dense_n[1][0] = registers_i[0][39:32];
        dense_n[1][1] = registers_i[0][47:40];
        dense_n[1][2] = registers_i[0][55:48];
        dense_n[1][3] = registers_i[0][63:56];
        dense_n[2][0] = registers_i[1][7:0];
        dense_n[2][1] = registers_i[1][15:8];
        dense_n[2][2] = registers_i[1][23:16];
        dense_n[2][3] = registers_i[1][31:24];
        dense_n[3][0] = registers_i[1][39:32];
        dense_n[3][1] = registers_i[1][47:40];  
        dense_n[3][2] = registers_i[1][55:48]; 
        dense_n[3][3] = registers_i[1][63:56];

        if (rs_valid_i == 2'b11) begin //make sure both registers are valid so that if there are invalid values in the registers that transfer dense_n, the multiplication is not executed
          for (int i = 0; i < 4; i++) begin
            ACC_n[i][0] = sparse_n[i][0]*dense_n[meta_data_n[i][0]][0] + sparse_n[i][1]*dense_n[meta_data_n[i][1]][0] + ACC_n[i][0];
            ACC_n[i][1] = sparse_n[i][0]*dense_n[meta_data_n[i][0]][1] + sparse_n[i][1]*dense_n[meta_data_n[i][1]][1] + ACC_n[i][1];
            ACC_n[i][2] = sparse_n[i][0]*dense_n[meta_data_n[i][0]][2] + sparse_n[i][1]*dense_n[meta_data_n[i][1]][2] + ACC_n[i][2];
            ACC_n[i][3] = sparse_n[i][0]*dense_n[meta_data_n[i][0]][3] + sparse_n[i][1]*dense_n[meta_data_n[i][1]][3] + ACC_n[i][3]; 
          end
        end
      end
      cvxif_instr_pkg::LOAD_SPARSE: begin
        /*sparse_n[0][0] = registers_i[0][63:56];
        sparse_n[0][1] = registers_i[0][55:48];
        sparse_n[1][0] = registers_i[0][47:40];
        sparse_n[1][1] = registers_i[0][39:32];
        sparse_n[2][0] = registers_i[0][31:24];
        sparse_n[2][1] = registers_i[0][23:16];
        sparse_n[3][0] = registers_i[0][15:8];
        sparse_n[3][1] = registers_i[0][7:0];

        meta_data_n[0][0] = registers_i[1][57:56];
        meta_data_n[0][1] = registers_i[1][49:48];
        meta_data_n[1][0] = registers_i[1][41:40];
        meta_data_n[1][1] = registers_i[1][33:32];
        meta_data_n[2][0] = registers_i[1][25:24];
        meta_data_n[2][1] = registers_i[1][17:16];
        meta_data_n[3][0] = registers_i[1][9:8];
        meta_data_n[3][1] = registers_i[1][1:0];*/

        sparse_n[0][0] = registers_i[0][7:0];
        sparse_n[0][1] = registers_i[0][15:8];
        sparse_n[1][0] = registers_i[0][23:16];
        sparse_n[1][1] = registers_i[0][31:24];
        sparse_n[2][0] = registers_i[0][39:32];
        sparse_n[2][1] = registers_i[0][47:40];
        sparse_n[3][0] = registers_i[0][55:48];
        sparse_n[3][1] = registers_i[0][63:56];

        meta_data_n[0][0] = registers_i[1][1:0];
        meta_data_n[0][1] = registers_i[1][9:8];
        meta_data_n[1][0] = registers_i[1][17:16];
        meta_data_n[1][1] = registers_i[1][25:24];
        meta_data_n[2][0] = registers_i[1][33:32];
        meta_data_n[2][1] = registers_i[1][41:40];
        meta_data_n[3][0] = registers_i[1][49:48];
        meta_data_n[3][1] = registers_i[1][57:56];
      end
      cvxif_instr_pkg::LOAD_SPARSE_START: begin
        /*Valid results for register_i[0] come after 2 cycles from when the instruction starts execution meaning the sparse_n array is invalid until the register_i[0] becomes valid
        (rs_valid == 0b11) and then and only then do we want the multiplication to take place because it changes the state of the ACC_n and there for in the next cycle the state of 
        ACC with invalid data that are needed in the multiplication process and produces incorrect results*/
        /*sparse_n[0][0] = registers_i[0][63:56];
        sparse_n[0][1] = registers_i[0][55:48];
        sparse_n[1][0] = registers_i[0][47:40];
        sparse_n[1][1] = registers_i[0][39:32];
        sparse_n[2][0] = registers_i[0][31:24];
        sparse_n[2][1] = registers_i[0][23:16];
        sparse_n[3][0] = registers_i[0][15:8];
        sparse_n[3][1] = registers_i[0][7:0];

        meta_data_n[0][0] = registers_i[1][57:56];
        meta_data_n[0][1] = registers_i[1][49:48];
        meta_data_n[1][0] = registers_i[1][41:40];
        meta_data_n[1][1] = registers_i[1][33:32];
        meta_data_n[2][0] = registers_i[1][25:24];
        meta_data_n[2][1] = registers_i[1][17:16];
        meta_data_n[3][0] = registers_i[1][9:8];
        meta_data_n[3][1] = registers_i[1][1:0];*/

        sparse_n[0][0] = registers_i[0][7:0];
        sparse_n[0][1] = registers_i[0][15:8];
        sparse_n[1][0] = registers_i[0][23:16];
        sparse_n[1][1] = registers_i[0][31:24];
        sparse_n[2][0] = registers_i[0][39:32];
        sparse_n[2][1] = registers_i[0][47:40];
        sparse_n[3][0] = registers_i[0][55:48];
        sparse_n[3][1] = registers_i[0][63:56];

        meta_data_n[0][0] = registers_i[1][1:0];
        meta_data_n[0][1] = registers_i[1][9:8];
        meta_data_n[1][0] = registers_i[1][17:16];
        meta_data_n[1][1] = registers_i[1][25:24];
        meta_data_n[2][0] = registers_i[1][33:32];
        meta_data_n[2][1] = registers_i[1][41:40];
        meta_data_n[3][0] = registers_i[1][49:48];
        meta_data_n[3][1] = registers_i[1][57:56];

        if (rs_valid_i == 2'b11) begin //make sure both registers are valid so that if there are invalid values in the registers that transfer to sparse_n or metadata_n, the multiplication is not executed
          for (int i = 0; i < 4; i++) begin
            ACC_n[i][0] = sparse_n[i][0]*dense_n[meta_data_n[i][0]][0] + sparse_n[i][1]*dense_n[meta_data_n[i][1]][0] + ACC_n[i][0];
            ACC_n[i][1] = sparse_n[i][0]*dense_n[meta_data_n[i][0]][1] + sparse_n[i][1]*dense_n[meta_data_n[i][1]][1] + ACC_n[i][1];
            ACC_n[i][2] = sparse_n[i][0]*dense_n[meta_data_n[i][0]][2] + sparse_n[i][1]*dense_n[meta_data_n[i][1]][2] + ACC_n[i][2];
            ACC_n[i][3] = sparse_n[i][0]*dense_n[meta_data_n[i][0]][3] + sparse_n[i][1]*dense_n[meta_data_n[i][1]][3] + ACC_n[i][3]; 
          end
        end
      end
      cvxif_instr_pkg::STORE_ACC0: begin
        result_n = {ACC[0][0],ACC[0][1]};  
        we_n     = 1'b1;
      end
      cvxif_instr_pkg::STORE_ACC2: begin
        result_n = {ACC[0][2],ACC[0][3]};
        we_n     = 1'b1;
      end
      cvxif_instr_pkg::STORE_ACC4: begin
        result_n = {ACC[1][0],ACC[1][1]};
        we_n     = 1'b1;
      end
      cvxif_instr_pkg::STORE_ACC6: begin
        result_n = {ACC[1][2],ACC[1][3]};
        we_n     = 1'b1;
      end
      cvxif_instr_pkg::STORE_ACC8: begin
        result_n = {ACC[2][0],ACC[2][1]};
        we_n     = 1'b1;
      end
      cvxif_instr_pkg::STORE_ACC10: begin
        result_n = {ACC[2][2],ACC[2][3]};
        we_n     = 1'b1;
      end
      cvxif_instr_pkg::STORE_ACC12: begin
        result_n = {ACC[3][0],ACC[3][1]};
        we_n     = 1'b1;
      end
      cvxif_instr_pkg::STORE_ACC14 : begin
        result_n = {ACC[3][2],ACC[3][3]};
        we_n     = 1'b1;
      end
      default: begin
        result_n = '0;
        hartid_n = '0;
        id_n     = '0;
        valid_n  = '0;
        rd_n     = '0;
        we_n     = '0;
      end
    endcase
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      result_q <= '0;
      hartid_q <= '0;
      id_q     <= '0;
      valid_q  <= '0;
      rd_q     <= '0;
      we_q     <= '0;
      ACC[0] <= {32'b0, 32'b0, 32'b0, 32'b0};
      ACC[1] <= {32'b0, 32'b0, 32'b0, 32'b0};
      ACC[2] <= {32'b0, 32'b0, 32'b0, 32'b0};
      ACC[3] <= {32'b0, 32'b0, 32'b0, 32'b0};
      dense[0] <= {8'b0, 8'b0, 8'b0, 8'b0};  
      dense[1] <= {8'b0, 8'b0, 8'b0, 8'b0}; 
      dense[2] <= {8'b0, 8'b0, 8'b0, 8'b0};
      dense[3] <= {8'b0, 8'b0, 8'b0, 8'b0};
      sparse[0] <= {8'b0, 8'b0};
      sparse[1] <= {8'b0, 8'b0};
      sparse[2] <= {8'b0, 8'b0};
      sparse[3] <= {8'b0, 8'b0};
      meta_data[0] <= {2'b0, 2'b0};
      meta_data[1] <= {2'b0, 2'b0};
      meta_data[2] <= {2'b0, 2'b0};
      meta_data[3] <= {2'b0, 2'b0};
    end else begin
      result_q  <= result_n;
      hartid_q  <= hartid_n;
      id_q      <= id_n;
      valid_q   <= valid_n;
      rd_q      <= rd_n;
      we_q      <= we_n;
      ACC       <= ACC_n;
      dense     <= dense_n;
      sparse    <= sparse_n;
      meta_data <= meta_data_n;
    end
  end

endmodule
