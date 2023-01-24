// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2023 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0

package p;
typedef enum { A = 1, B = 2, C = 3 } test_enum;
endpackage

module t (/*AUTOARG*/
   // Inputs
   clk
   );
   input clk;

   integer v;

   import p::*;
   parameter A = 10;

   assign v = A;

   always @ (posedge clk) begin
      if (v !== 10) $stop;
      $write("*-* All Finished *-*\n");
      $finish;
   end

endmodule
