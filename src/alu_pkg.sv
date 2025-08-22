package alu_pkg;
import uvm_pkg::*;
`include "alu_seq_items.sv"
`include "alu_sequence.sv"
`include "alu_sequencer.sv"
`include "alu_driver.sv"
`include "alu_monitor.sv"
/* `include "alu_monitor_passive.sv" */
`include "alu_agent.sv"

/* `include "alu_agent_passive.sv" */
`include "alu_scoreboard.sv"
`include "alu_coverage.sv"
`include "alu_env.sv"
`include "test.sv"
endpackage
