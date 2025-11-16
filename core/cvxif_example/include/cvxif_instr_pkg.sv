// Copyright 2021 Thales DIS design services SAS
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
// You may obtain a copy of the License at https://solderpad.org/licenses/
//
// Original Author: Guillaume Chauvon (guillaume.chauvon@thalesgroup.com)



package cvxif_instr_pkg;

  typedef enum logic [3:0] {
    ILLEGAL           = 4'b0000,
    RESET_ACC         = 4'b0001,
    LOAD_DENSE        = 4'b0010,
    LOAD_DENSE_START  = 4'b0011,
    LOAD_SPARSE       = 4'b0100,
    LOAD_SPARSE_START = 4'b0101,
    STORE_ACC0        = 4'b0110,
    STORE_ACC2        = 4'b0111,
    STORE_ACC4        = 4'b1000,
    STORE_ACC6        = 4'b1001,
    STORE_ACC8        = 4'b1010,
    STORE_ACC10       = 4'b1011,
    STORE_ACC12       = 4'b1100,
    STORE_ACC14       = 4'b1101
  } opcode_t;

  typedef struct packed {
    logic accept;
    logic writeback;  // TODO depends on dualwrite
    logic [2:0] register_read;  // TODO Nr read ports
  } issue_resp_t;

  typedef struct packed {
    logic        accept;
    logic [31:0] instr;
  } compressed_resp_t;

  typedef struct packed {
    logic [31:0] instr;
    logic [31:0] mask;
    issue_resp_t resp;
    opcode_t     opcode;
  } copro_issue_resp_t;

  typedef struct packed {
    logic [15:0]      instr;
    logic [15:0]      mask;
    compressed_resp_t resp;
  } copro_compressed_resp_t;

  // 4 Possible RISCV instructions for Coprocessor
  parameter int unsigned NbInstr = 13;
  parameter copro_issue_resp_t CoproInstr[NbInstr] = '{
      '{
          // Custom RESET_ACC
          instr:
          32'b00000_00_00000_00000_0_00_00000_0001011,  
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b0, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : RESET_ACC
      },
      '{
          // Custom Load Dense : ld_dense rs1, rs2
          instr:
          32'b00000_00_00000_00000_0_01_00000_0001011,  
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b0, register_read : {1'b0, 1'b1, 1'b1}},
          opcode : LOAD_DENSE
      },
      '{
          // Custom Load Dense Start: ld_dense_start rs1, rs2
          instr:
          32'b00000_01_00000_00000_0_01_00000_0001011,  
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b0, register_read : {1'b0, 1'b1, 1'b1}},
          opcode : LOAD_DENSE_START
      },
      '{
          // Custom Load Sparse : ld_sparse rs1, rs2
          instr:
          32'b00000_00_00000_00000_0_10_00000_0001011,  
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b0, register_read : {1'b0, 1'b1, 1'b1}},
          opcode : LOAD_SPARSE
      },
      '{
          // Custom Load Sparse Start: ld_sparse_start rs1, rs2
          instr:
          32'b00000_01_00000_00000_0_10_00000_0001011,  
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b0, register_read : {1'b0, 1'b1, 1'b1}},
          opcode : LOAD_SPARSE_START
      },
      '{
          // Custom Store ACC0 : st_acc0 rd
          instr:
          32'b00000_00_00000_00000_0_11_00000_0001011,  
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b1, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : STORE_ACC0
      },
      '{
          // Custom Store ACC2 : st_acc2 rd
          instr:
          32'b00000_10_00000_00000_0_11_00000_0001011,  
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b1, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : STORE_ACC2
      },
      '{
          // Custom Store ACC4 : st_acc4 rd
          instr:
          32'b00001_00_00000_00000_0_11_00000_0001011,  
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b1, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : STORE_ACC4
      },
      '{
          // Custom Store ACC6 : st_acc6 rd
          instr:
          32'b00001_10_00000_00000_0_11_00000_0001011,  
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b1, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : STORE_ACC6
      },
      '{
          // Custom Store ACC8 : st_acc8 rd
          instr:
          32'b00010_00_00000_00000_0_11_00000_0001011,  
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b1, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : STORE_ACC8
      },
      '{
          // Custom Store ACC10 : st_acc10 rd
          instr:
          32'b00010_10_00000_00000_0_11_00000_0001011,  
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b1, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : STORE_ACC10
      },
      '{
          // Custom Store ACC12 : st_acc12 rd
          instr:
          32'b00011_00_00000_00000_0_11_00000_0001011,  
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b1, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : STORE_ACC12
      },
      '{
          // Custom Store ACC14 : st_acc14 rd
          instr:
          32'b00011_10_00000_00000_0_11_00000_0001011,  
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b1, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : STORE_ACC14
      }
  };

  parameter int unsigned NbCompInstr = 2;
  parameter copro_compressed_resp_t CoproCompInstr[NbCompInstr] = '{
      // C_NOP
      '{
          instr : 16'b111_0_00000_00000_00,
          mask : 16'b111_1_00000_00000_11,
          resp : '{accept : 1'b1, instr : 32'b00000_00_00000_00000_0_00_00000_1111011}
      },
      '{
          instr : 16'b111_1_00000_00000_00,
          mask : 16'b111_1_00000_00000_11,
          resp : '{accept : 1'b1, instr : 32'b00000_00_00000_00000_0_01_01010_1111011}
      }
  };
  
endpackage
