// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: I2C core module

module i2c_core import i2c_pkg::*;
(
  input                            clk_i,
  input                            rst_ni,

  input i2c_reg_pkg::i2c_reg2hw_t  reg2hw,
  output i2c_reg_pkg::i2c_hw2reg_t hw2reg,

  input                            scl_i,
  output logic                     scl_o,
  input                            sda_i,
  output logic                     sda_o,

  output logic                     intr_fmt_threshold_o,
  output logic                     intr_rx_threshold_o,
  output logic                     intr_acq_threshold_o,
  output logic                     intr_rx_overflow_o,
  output logic                     intr_nak_o,
  output logic                     intr_scl_interference_o,
  output logic                     intr_sda_interference_o,
  output logic                     intr_stretch_timeout_o,
  output logic                     intr_sda_unstable_o,
  output logic                     intr_cmd_complete_o,
  output logic                     intr_tx_stretch_o,
  output logic                     intr_tx_threshold_o,
  output logic                     intr_acq_full_o,
  output logic                     intr_unexp_stop_o,
  output logic                     intr_host_timeout_o
);

  import i2c_reg_pkg::FifoDepth;
  import i2c_reg_pkg::AcqFifoDepth;

  // Number of bits required to represent the FIFO level/depth.
  localparam int unsigned FifoDepthW = $clog2(FifoDepth + 1);
  localparam int unsigned AcqFifoDepthW = $clog2(AcqFifoDepth+1);

  // Maximum number of bits required to represent the level/depth of any FIFO.
  localparam int unsigned MaxFifoDepthW = 12;

  logic [15:0] thigh;
  logic [15:0] tlow;
  logic [15:0] t_r;
  logic [15:0] t_f;
  logic [15:0] thd_sta;
  logic [15:0] tsu_sta;
  logic [15:0] tsu_sto;
  logic [15:0] tsu_dat;
  logic [15:0] thd_dat;
  logic [15:0] t_buf;
  logic [30:0] stretch_timeout;
  logic        timeout_enable;
  logic [31:0] host_timeout;

  logic scl_sync;
  logic sda_sync;
  logic scl_out_fsm;
  logic sda_out_fsm;

  logic event_rx_overflow;
  logic event_nak;
  logic event_scl_interference;
  logic event_sda_interference;
  logic event_stretch_timeout;
  logic event_sda_unstable;
  logic event_cmd_complete;
  logic event_tx_stretch;
  logic event_unexp_stop;
  logic event_host_timeout;

  logic [15:0] scl_rx_val;
  logic [15:0] sda_rx_val;

  logic override;

  logic                     fmt_fifo_wvalid;
  logic                     fmt_fifo_wready;
  logic [12:0]              fmt_fifo_wdata;
  logic [FifoDepthW-1:0]    fmt_fifo_depth;
  logic                     fmt_fifo_rvalid;
  logic                     fmt_fifo_rready;
  logic [12:0]              fmt_fifo_rdata;
  logic [7:0]               fmt_byte;
  logic                     fmt_flag_start_before;
  logic                     fmt_flag_stop_after;
  logic                     fmt_flag_read_bytes;
  logic                     fmt_flag_read_continue;
  logic                     fmt_flag_nak_ok;

  logic                     i2c_fifo_rxrst;
  logic                     i2c_fifo_fmtrst;
  logic [MaxFifoDepthW-1:0] i2c_fifo_rx_thresh;
  logic [MaxFifoDepthW-1:0] i2c_fifo_fmt_thresh;

  logic                     rx_fifo_wvalid;
  logic                     rx_fifo_wready;
  logic [7:0]               rx_fifo_wdata;
  logic [FifoDepthW-1:0]    rx_fifo_depth;
  logic                     rx_fifo_rvalid;
  logic                     rx_fifo_rready;
  logic [7:0]               rx_fifo_rdata;

  // FMT FIFO level below programmed threshold?
  logic                     fmt_lt_threshold;
  // Rx FIFO level above programmed threshold?
  logic                     rx_gt_threshold;

  logic                     tx_fifo_wvalid;
  logic                     tx_fifo_wready;
  logic [7:0]               tx_fifo_wdata;
  logic [FifoDepthW-1:0]    tx_fifo_depth;
  logic                     tx_fifo_rvalid;
  logic                     tx_fifo_rready;
  logic [7:0]               tx_fifo_rdata;

  logic                     acq_fifo_wvalid;
  logic                     acq_fifo_wready;
  logic [9:0]               acq_fifo_wdata;
  logic [AcqFifoDepthW-1:0] acq_fifo_depth;
  logic                     acq_fifo_rvalid;
  logic                     acq_fifo_rready;
  logic [9:0]               acq_fifo_rdata;

  logic                     i2c_fifo_txrst;
  logic                     i2c_fifo_acqrst;
  logic [MaxFifoDepthW-1:0] i2c_fifo_tx_thresh;
  logic [MaxFifoDepthW-1:0] i2c_fifo_acq_thresh;

  // Tx FIFO level below programmed threshold?
  logic        tx_lt_threshold;
  // ACQ FIFO level above programmed threshold?
  logic        acq_gt_threshold;

  logic        host_idle;
  logic        target_idle;

  logic        host_enable;
  logic        target_enable;
  logic        line_loopback;
  logic        target_loopback;

  logic [6:0]  target_address0;
  logic [6:0]  target_mask0;
  logic [6:0]  target_address1;
  logic [6:0]  target_mask1;

  // Unused parts of exposed bits
  logic        unused_rx_thr_qe;
  logic        unused_fmt_thr_qe;
  logic        unused_tx_thr_qe;
  logic        unused_acq_thr_qe;
  logic [7:0]  unused_rx_fifo_rdata_q;
  logic [7:0]  unused_acq_fifo_adata_q;
  logic [1:0]  unused_acq_fifo_signal_q;
  logic        unused_alert_test_qe;
  logic        unused_alert_test_q;

  assign hw2reg.status.fmtfull.d = ~fmt_fifo_wready;
  assign hw2reg.status.rxfull.d = ~rx_fifo_wready;
  assign hw2reg.status.fmtempty.d = ~fmt_fifo_rvalid;
  assign hw2reg.status.hostidle.d = host_idle;
  assign hw2reg.status.targetidle.d = target_idle;
  assign hw2reg.status.rxempty.d = ~rx_fifo_rvalid;
  assign hw2reg.rdata.d = rx_fifo_rdata;
  assign hw2reg.host_fifo_status.fmtlvl.d = MaxFifoDepthW'(fmt_fifo_depth);
  assign hw2reg.host_fifo_status.rxlvl.d = MaxFifoDepthW'(rx_fifo_depth);
  assign hw2reg.val.scl_rx.d = scl_rx_val;
  assign hw2reg.val.sda_rx.d = sda_rx_val;

  assign hw2reg.status.txfull.d = ~tx_fifo_wready;
  assign hw2reg.status.acqfull.d = ~acq_fifo_wready;
  assign hw2reg.status.txempty.d = ~tx_fifo_rvalid;
  assign hw2reg.status.acqempty.d = ~acq_fifo_rvalid;
  assign hw2reg.target_fifo_status.txlvl.d = MaxFifoDepthW'(tx_fifo_depth);
  assign hw2reg.target_fifo_status.acqlvl.d = MaxFifoDepthW'(acq_fifo_depth);
  assign hw2reg.acqdata.abyte.d = acq_fifo_rdata[7:0];
  assign hw2reg.acqdata.signal.d = acq_fifo_rdata[9:8];

  assign override = reg2hw.ovrd.txovrden;

  assign scl_o = override ? reg2hw.ovrd.sclval : scl_out_fsm;
  assign sda_o = override ? reg2hw.ovrd.sdaval : sda_out_fsm;

  assign host_enable = reg2hw.ctrl.enablehost.q;
  assign target_enable = reg2hw.ctrl.enabletarget.q;
  assign line_loopback = reg2hw.ctrl.llpbk.q;

  // Target loopback simply plays back whatever is received from the external host
  // back to it.
  assign target_loopback = target_enable & line_loopback;

  assign target_address0 = reg2hw.target_id.address0.q;
  assign target_mask0 = reg2hw.target_id.mask0.q;
  assign target_address1 = reg2hw.target_id.address1.q;
  assign target_mask1 = reg2hw.target_id.mask1.q;

  // Sample scl_i and sda_i at system clock
  always_ff @ (posedge clk_i or negedge rst_ni) begin : rx_oversampling
    if(!rst_ni) begin
       scl_rx_val <= 16'h0;
       sda_rx_val <= 16'h0;
    end else begin
       scl_rx_val <= {scl_rx_val[14:0], scl_i};
       sda_rx_val <= {sda_rx_val[14:0], sda_i};
    end
  end

  assign thigh           = reg2hw.timing0.thigh.q;
  assign tlow            = reg2hw.timing0.tlow.q;
  assign t_r             = reg2hw.timing1.t_r.q;
  assign t_f             = reg2hw.timing1.t_f.q;
  assign tsu_sta         = reg2hw.timing2.tsu_sta.q;
  assign thd_sta         = reg2hw.timing2.thd_sta.q;
  assign tsu_dat         = reg2hw.timing3.tsu_dat.q;
  assign thd_dat         = reg2hw.timing3.thd_dat.q;
  assign tsu_sto         = reg2hw.timing4.tsu_sto.q;
  assign t_buf           = reg2hw.timing4.t_buf.q;
  assign stretch_timeout = reg2hw.timeout_ctrl.val.q;
  assign timeout_enable  = reg2hw.timeout_ctrl.en.q;
  assign host_timeout    = reg2hw.host_timeout_ctrl.q;

  assign i2c_fifo_rxrst      = reg2hw.fifo_ctrl.rxrst.q & reg2hw.fifo_ctrl.rxrst.qe;
  assign i2c_fifo_fmtrst     = reg2hw.fifo_ctrl.fmtrst.q & reg2hw.fifo_ctrl.fmtrst.qe;
  assign i2c_fifo_rx_thresh  = reg2hw.host_fifo_config.rx_thresh.q;
  assign i2c_fifo_fmt_thresh = reg2hw.host_fifo_config.fmt_thresh.q;

  assign i2c_fifo_txrst      = reg2hw.fifo_ctrl.txrst.q & reg2hw.fifo_ctrl.txrst.qe;
  assign i2c_fifo_acqrst     = reg2hw.fifo_ctrl.acqrst.q & reg2hw.fifo_ctrl.acqrst.qe;
  assign i2c_fifo_tx_thresh  = reg2hw.target_fifo_config.tx_thresh.q;
  assign i2c_fifo_acq_thresh = reg2hw.target_fifo_config.acq_thresh.q;

  // FMT FIFO level below programmed threshold?
  assign fmt_lt_threshold = (MaxFifoDepthW'(fmt_fifo_depth) < i2c_fifo_fmt_thresh);
  // Rx FIFO level above programmed threshold?
  assign rx_gt_threshold  = (MaxFifoDepthW'(rx_fifo_depth)  > i2c_fifo_rx_thresh);
  // Tx FIFO level below programmed threshold?
  assign tx_lt_threshold  = (MaxFifoDepthW'(tx_fifo_depth)  < i2c_fifo_tx_thresh);
  // ACQ FIFO level above programmed threshold?
  assign acq_gt_threshold = (MaxFifoDepthW'(acq_fifo_depth) > i2c_fifo_acq_thresh);

  assign event_rx_overflow = rx_fifo_wvalid & ~rx_fifo_wready;

  // The fifo write enable is controlled by fbyte, start, stop, read, rcont,
  // and nakok field qe bits.
  // When all qe bits are asserted, fdata is injected into the fifo.
  assign fmt_fifo_wvalid     = reg2hw.fdata.fbyte.qe &
                               reg2hw.fdata.start.qe &
                               reg2hw.fdata.stop.qe  &
                               reg2hw.fdata.readb.qe  &
                               reg2hw.fdata.rcont.qe &
                               reg2hw.fdata.nakok.qe;
  assign fmt_fifo_wdata[7:0] = reg2hw.fdata.fbyte.q;
  assign fmt_fifo_wdata[8]   = reg2hw.fdata.start.q;
  assign fmt_fifo_wdata[9]   = reg2hw.fdata.stop.q;
  assign fmt_fifo_wdata[10]  = reg2hw.fdata.readb.q;
  assign fmt_fifo_wdata[11]  = reg2hw.fdata.rcont.q;
  assign fmt_fifo_wdata[12]  = reg2hw.fdata.nakok.q;

  assign fmt_byte               = fmt_fifo_rvalid ? fmt_fifo_rdata[7:0] : '0;
  assign fmt_flag_start_before  = fmt_fifo_rvalid ? fmt_fifo_rdata[8] : '0;
  assign fmt_flag_stop_after    = fmt_fifo_rvalid ? fmt_fifo_rdata[9] : '0;
  assign fmt_flag_read_bytes    = fmt_fifo_rvalid ? fmt_fifo_rdata[10] : '0;
  assign fmt_flag_read_continue = fmt_fifo_rvalid ? fmt_fifo_rdata[11] : '0;
  assign fmt_flag_nak_ok        = fmt_fifo_rvalid ? fmt_fifo_rdata[12] : '0;

  // Unused parts of exposed bits
  assign unused_rx_thr_qe  = reg2hw.host_fifo_config.rx_thresh.qe;
  assign unused_fmt_thr_qe = reg2hw.host_fifo_config.fmt_thresh.qe;
  assign unused_tx_thr_qe  = reg2hw.target_fifo_config.tx_thresh.qe;
  assign unused_acq_thr_qe = reg2hw.target_fifo_config.acq_thresh.qe;
  assign unused_rx_fifo_rdata_q = reg2hw.rdata.q;
  assign unused_acq_fifo_adata_q = reg2hw.acqdata.abyte.q;
  assign unused_acq_fifo_signal_q = reg2hw.acqdata.signal.q;
  assign unused_alert_test_qe = reg2hw.alert_test.qe;
  assign unused_alert_test_q = reg2hw.alert_test.q;

  prim_fifo_sync #(
    .Width   (13),
    .Pass    (1'b0),
    .Depth   (FifoDepth)
  ) u_i2c_fmtfifo (
    .clk_i,
    .rst_ni,
    .clr_i   (i2c_fifo_fmtrst),
    .wvalid_i(fmt_fifo_wvalid),
    .wready_o(fmt_fifo_wready),
    .wdata_i (fmt_fifo_wdata),
    .depth_o (fmt_fifo_depth),
    .rvalid_o(fmt_fifo_rvalid),
    .rready_i(fmt_fifo_rready),
    .rdata_o (fmt_fifo_rdata),
    .full_o  (),
    .err_o   ()
  );

  assign rx_fifo_rready = reg2hw.rdata.re;

  prim_fifo_sync #(
    .Width   (8),
    .Pass    (1'b0),
    .Depth   (FifoDepth)
  ) u_i2c_rxfifo (
    .clk_i,
    .rst_ni,
    .clr_i   (i2c_fifo_rxrst),
    .wvalid_i(rx_fifo_wvalid),
    .wready_o(rx_fifo_wready),
    .wdata_i (rx_fifo_wdata),
    .depth_o (rx_fifo_depth),
    .rvalid_o(rx_fifo_rvalid),
    .rready_i(rx_fifo_rready),
    .rdata_o (rx_fifo_rdata),
    .full_o  (),
    .err_o   ()
  );

  // Need to add a valid qualification to write only payload bytes
  logic valid_target_lb_wr;
  i2c_acq_byte_id_e acq_type;
  assign acq_type = i2c_acq_byte_id_e'(acq_fifo_rdata[9:8]);

  assign valid_target_lb_wr = target_enable & (acq_type == AcqData);

  // only write into tx fifo if it's payload
  assign tx_fifo_wvalid = target_loopback ? acq_fifo_rvalid & valid_target_lb_wr : reg2hw.txdata.qe;
  assign tx_fifo_wdata  = target_loopback ? acq_fifo_rdata[7:0] : reg2hw.txdata.q;

  prim_fifo_sync #(
    .Width(8),
    .Pass(1'b0),
    .Depth(FifoDepth)
  ) u_i2c_txfifo (
    .clk_i,
    .rst_ni,
    .clr_i   (i2c_fifo_txrst),
    .wvalid_i(tx_fifo_wvalid),
    .wready_o(tx_fifo_wready),
    .wdata_i (tx_fifo_wdata),
    .depth_o (tx_fifo_depth),
    .rvalid_o(tx_fifo_rvalid),
    .rready_i(tx_fifo_rready),
    .rdata_o (tx_fifo_rdata),
    .full_o  (),
    .err_o   ()
  );

  // During line loopback, pop from acquisition fifo only when there is space in
  // the tx_fifo.  We are also allowed to pop even if there is no space if th acq entry
  // is not data payload.
  assign acq_fifo_rready = (reg2hw.acqdata.abyte.re & reg2hw.acqdata.signal.re) |
                           (target_loopback & (tx_fifo_wready | (acq_type != AcqData)));

  prim_fifo_sync #(
    .Width(10),
    .Pass(1'b0),
    .Depth(AcqFifoDepth)
  ) u_i2c_acqfifo (
    .clk_i,
    .rst_ni,
    .clr_i   (i2c_fifo_acqrst),
    .wvalid_i(acq_fifo_wvalid),
    .wready_o(),
    .wdata_i (acq_fifo_wdata),
    .depth_o (acq_fifo_depth),
    .rvalid_o(acq_fifo_rvalid),
    .rready_i(acq_fifo_rready),
    .rdata_o (acq_fifo_rdata),
    .full_o  (),
    .err_o   ()
  );

  // sync the incoming SCL and SDA signals
  prim_flop_2sync #(
    .Width(1),
    .ResetValue(1'b1)
  ) u_i2c_sync_scl (
    .clk_i,
    .rst_ni,
    .d_i (scl_i),
    .q_o (scl_sync)
  );

  prim_flop_2sync #(
    .Width(1),
    .ResetValue(1'b1)
  ) u_i2c_sync_sda (
    .clk_i,
    .rst_ni,
    .d_i (sda_i),
    .q_o (sda_sync)
  );

  i2c_fsm #(
    .FifoDepth(FifoDepth),
    .AcqFifoDepth(AcqFifoDepth)
  ) u_i2c_fsm (
    .clk_i,
    .rst_ni,

    .scl_i                   (scl_sync),
    .scl_o                   (scl_out_fsm),
    .sda_i                   (sda_sync),
    .sda_o                   (sda_out_fsm),

    .host_enable_i           (host_enable),
    .target_enable_i         (target_enable),

    .fmt_fifo_rvalid_i       (fmt_fifo_rvalid),
    .fmt_fifo_wvalid_i       (fmt_fifo_wvalid),
    .fmt_fifo_depth_i        (fmt_fifo_depth),
    .fmt_fifo_rready_o       (fmt_fifo_rready),

    .fmt_byte_i              (fmt_byte),
    .fmt_flag_start_before_i (fmt_flag_start_before),
    .fmt_flag_stop_after_i   (fmt_flag_stop_after),
    .fmt_flag_read_bytes_i   (fmt_flag_read_bytes),
    .fmt_flag_read_continue_i(fmt_flag_read_continue),
    .fmt_flag_nak_ok_i       (fmt_flag_nak_ok),

    .rx_fifo_wvalid_o        (rx_fifo_wvalid),
    .rx_fifo_wdata_o         (rx_fifo_wdata),

    .tx_fifo_rvalid_i        (tx_fifo_rvalid),
    .tx_fifo_wvalid_i        (tx_fifo_wvalid),
    .tx_fifo_depth_i         (tx_fifo_depth),
    .tx_fifo_rready_o        (tx_fifo_rready),
    .tx_fifo_rdata_i         (tx_fifo_rdata),

    .acq_fifo_wready_o       (acq_fifo_wready),
    .acq_fifo_wvalid_o       (acq_fifo_wvalid),
    .acq_fifo_wdata_o        (acq_fifo_wdata),
    .acq_fifo_rdata_i        (acq_fifo_rdata),
    .acq_fifo_depth_i        (acq_fifo_depth),

    .host_idle_o             (host_idle),
    .target_idle_o           (target_idle),

    .thigh_i                 (thigh),
    .tlow_i                  (tlow),
    .t_r_i                   (t_r),
    .t_f_i                   (t_f),
    .thd_sta_i               (thd_sta),
    .tsu_sta_i               (tsu_sta),
    .tsu_sto_i               (tsu_sto),
    .tsu_dat_i               (tsu_dat),
    .thd_dat_i               (thd_dat),
    .t_buf_i                 (t_buf),
    .stretch_timeout_i       (stretch_timeout),
    .timeout_enable_i        (timeout_enable),
    .host_timeout_i          (host_timeout),
    .target_address0_i       (target_address0),
    .target_mask0_i          (target_mask0),
    .target_address1_i       (target_address1),
    .target_mask1_i          (target_mask1),
    .event_nak_o             (event_nak),
    .event_scl_interference_o(event_scl_interference),
    .event_sda_interference_o(event_sda_interference),
    .event_stretch_timeout_o (event_stretch_timeout),
    .event_sda_unstable_o    (event_sda_unstable),
    .event_cmd_complete_o    (event_cmd_complete),
    .event_tx_stretch_o      (event_tx_stretch),
    .event_unexp_stop_o      (event_unexp_stop),
    .event_host_timeout_o    (event_host_timeout)
  );

  prim_intr_hw #(
    .Width(1),
    .IntrT("Status")
  ) intr_hw_fmt_threshold (
    .clk_i,
    .rst_ni,
    .event_intr_i           (fmt_lt_threshold),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.fmt_threshold.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.fmt_threshold.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.fmt_threshold.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.fmt_threshold.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.fmt_threshold.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.fmt_threshold.d),
    .intr_o                 (intr_fmt_threshold_o)
  );

  prim_intr_hw #(
    .Width(1),
    .IntrT("Status")
  ) intr_hw_rx_threshold (
    .clk_i,
    .rst_ni,
    .event_intr_i           (rx_gt_threshold),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.rx_threshold.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.rx_threshold.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.rx_threshold.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.rx_threshold.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.rx_threshold.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.rx_threshold.d),
    .intr_o                 (intr_rx_threshold_o)
  );

  prim_intr_hw #(
    .Width(1),
    .IntrT("Status")
  ) intr_hw_acq_threshold (
    .clk_i,
    .rst_ni,
    .event_intr_i           (acq_gt_threshold),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.acq_threshold.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.acq_threshold.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.acq_threshold.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.acq_threshold.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.acq_threshold.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.acq_threshold.d),
    .intr_o                 (intr_acq_threshold_o)
  );

  prim_intr_hw #(.Width(1)) intr_hw_rx_overflow (
    .clk_i,
    .rst_ni,
    .event_intr_i           (event_rx_overflow),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.rx_overflow.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.rx_overflow.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.rx_overflow.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.rx_overflow.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.rx_overflow.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.rx_overflow.d),
    .intr_o                 (intr_rx_overflow_o)
  );

  prim_intr_hw #(.Width(1)) intr_hw_nak (
    .clk_i,
    .rst_ni,
    .event_intr_i           (event_nak),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.nak.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.nak.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.nak.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.nak.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.nak.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.nak.d),
    .intr_o                 (intr_nak_o)
  );

  prim_intr_hw #(.Width(1)) intr_hw_scl_interference (
    .clk_i,
    .rst_ni,
    .event_intr_i           (event_scl_interference),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.scl_interference.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.scl_interference.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.scl_interference.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.scl_interference.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.scl_interference.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.scl_interference.d),
    .intr_o                 (intr_scl_interference_o)
  );

  prim_intr_hw #(.Width(1)) intr_hw_sda_interference (
    .clk_i,
    .rst_ni,
    .event_intr_i           (event_sda_interference),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.sda_interference.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.sda_interference.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.sda_interference.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.sda_interference.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.sda_interference.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.sda_interference.d),
    .intr_o                 (intr_sda_interference_o)
  );

  prim_intr_hw #(.Width(1)) intr_hw_stretch_timeout (
    .clk_i,
    .rst_ni,
    .event_intr_i           (event_stretch_timeout),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.stretch_timeout.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.stretch_timeout.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.stretch_timeout.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.stretch_timeout.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.stretch_timeout.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.stretch_timeout.d),
    .intr_o                 (intr_stretch_timeout_o)
  );

  prim_intr_hw #(.Width(1)) intr_hw_sda_unstable (
    .clk_i,
    .rst_ni,
    .event_intr_i           (event_sda_unstable),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.sda_unstable.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.sda_unstable.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.sda_unstable.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.sda_unstable.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.sda_unstable.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.sda_unstable.d),
    .intr_o                 (intr_sda_unstable_o)
  );

  prim_intr_hw #(.Width(1)) intr_hw_cmd_complete (
    .clk_i,
    .rst_ni,
    .event_intr_i           (event_cmd_complete),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.cmd_complete.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.cmd_complete.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.cmd_complete.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.cmd_complete.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.cmd_complete.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.cmd_complete.d),
    .intr_o                 (intr_cmd_complete_o)
  );

  prim_intr_hw #(
    .Width(1),
    .IntrT("Status")
  ) intr_hw_tx_stretch (
    .clk_i,
    .rst_ni,
    .event_intr_i           (event_tx_stretch),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.tx_stretch.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.tx_stretch.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.tx_stretch.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.tx_stretch.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.tx_stretch.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.tx_stretch.d),
    .intr_o                 (intr_tx_stretch_o)
  );

  prim_intr_hw #(
    .Width(1),
    .IntrT("Status")
  ) intr_hw_tx_threshold (
    .clk_i,
    .rst_ni,
    .event_intr_i           (tx_lt_threshold),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.tx_threshold.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.tx_threshold.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.tx_threshold.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.tx_threshold.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.tx_threshold.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.tx_threshold.d),
    .intr_o                 (intr_tx_threshold_o)
  );

  prim_intr_hw #(
    .Width(1),
    .IntrT("Status")
  ) intr_hw_acq_overflow (
    .clk_i,
    .rst_ni,
    .event_intr_i           (~acq_fifo_wready),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.acq_full.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.acq_full.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.acq_full.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.acq_full.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.acq_full.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.acq_full.d),
    .intr_o                 (intr_acq_full_o)
  );

  prim_intr_hw #(.Width(1)) intr_hw_unexp_stop (
    .clk_i,
    .rst_ni,
    .event_intr_i           (event_unexp_stop),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.unexp_stop.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.unexp_stop.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.unexp_stop.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.unexp_stop.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.unexp_stop.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.unexp_stop.d),
    .intr_o                 (intr_unexp_stop_o)
  );

  prim_intr_hw #(.Width(1)) intr_hw_host_timeout (
    .clk_i,
    .rst_ni,
    .event_intr_i           (event_host_timeout),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.host_timeout.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.host_timeout.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.host_timeout.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.host_timeout.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.host_timeout.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.host_timeout.d),
    .intr_o                 (intr_host_timeout_o)
  );

  `ASSERT_INIT(FifoDepthValid_A, FifoDepth > 0 && FifoDepthW <= MaxFifoDepthW)
  `ASSERT_INIT(AcqFifoDepthValid_A, AcqFifoDepth > 0 && AcqFifoDepthW <= MaxFifoDepthW)

endmodule
