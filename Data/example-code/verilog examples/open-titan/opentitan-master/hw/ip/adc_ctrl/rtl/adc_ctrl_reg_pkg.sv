// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package adc_ctrl_reg_pkg;

  // Param list
  parameter int NumAdcFilter = 8;
  parameter int NumAdcChannel = 2;
  parameter int NumAlerts = 1;

  // Address widths within the block
  parameter int BlockAw = 7;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    logic        q;
  } adc_ctrl_reg2hw_intr_state_reg_t;

  typedef struct packed {
    logic        q;
  } adc_ctrl_reg2hw_intr_enable_reg_t;

  typedef struct packed {
    logic        q;
    logic        qe;
  } adc_ctrl_reg2hw_intr_test_reg_t;

  typedef struct packed {
    logic        q;
    logic        qe;
  } adc_ctrl_reg2hw_alert_test_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } oneshot_mode;
    struct packed {
      logic        q;
    } adc_enable;
  } adc_ctrl_reg2hw_adc_en_ctl_reg_t;

  typedef struct packed {
    struct packed {
      logic [23:0] q;
    } wakeup_time;
    struct packed {
      logic [3:0]  q;
    } pwrup_time;
    struct packed {
      logic        q;
    } lp_mode;
  } adc_ctrl_reg2hw_adc_pd_ctl_reg_t;

  typedef struct packed {
    logic [7:0]  q;
  } adc_ctrl_reg2hw_adc_lp_sample_ctl_reg_t;

  typedef struct packed {
    logic [15:0] q;
  } adc_ctrl_reg2hw_adc_sample_ctl_reg_t;

  typedef struct packed {
    logic        q;
  } adc_ctrl_reg2hw_adc_fsm_rst_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } en;
    struct packed {
      logic [9:0] q;
    } max_v;
    struct packed {
      logic        q;
    } cond;
    struct packed {
      logic [9:0] q;
    } min_v;
  } adc_ctrl_reg2hw_adc_chn0_filter_ctl_mreg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } en;
    struct packed {
      logic [9:0] q;
    } max_v;
    struct packed {
      logic        q;
    } cond;
    struct packed {
      logic [9:0] q;
    } min_v;
  } adc_ctrl_reg2hw_adc_chn1_filter_ctl_mreg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } trans_en;
    struct packed {
      logic [7:0]  q;
    } match_en;
  } adc_ctrl_reg2hw_adc_wakeup_ctl_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } trans;
    struct packed {
      logic [7:0]  q;
    } match;
  } adc_ctrl_reg2hw_filter_status_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } oneshot_en;
    struct packed {
      logic        q;
    } trans_en;
    struct packed {
      logic [7:0]  q;
    } match_en;
  } adc_ctrl_reg2hw_adc_intr_ctl_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } oneshot;
    struct packed {
      logic        q;
    } trans;
    struct packed {
      logic [7:0]  q;
    } match;
  } adc_ctrl_reg2hw_adc_intr_status_reg_t;

  typedef struct packed {
    logic        d;
    logic        de;
  } adc_ctrl_hw2reg_intr_state_reg_t;

  typedef struct packed {
    struct packed {
      logic [1:0]  d;
      logic        de;
    } adc_chn_value_ext;
    struct packed {
      logic [9:0] d;
      logic        de;
    } adc_chn_value;
    struct packed {
      logic [1:0]  d;
      logic        de;
    } adc_chn_value_intr_ext;
    struct packed {
      logic [9:0] d;
      logic        de;
    } adc_chn_value_intr;
  } adc_ctrl_hw2reg_adc_chn_val_mreg_t;

  typedef struct packed {
    struct packed {
      logic [7:0]  d;
      logic        de;
    } match;
    struct packed {
      logic        d;
      logic        de;
    } trans;
  } adc_ctrl_hw2reg_filter_status_reg_t;

  typedef struct packed {
    struct packed {
      logic [7:0]  d;
      logic        de;
    } match;
    struct packed {
      logic        d;
      logic        de;
    } trans;
    struct packed {
      logic        d;
      logic        de;
    } oneshot;
  } adc_ctrl_hw2reg_adc_intr_status_reg_t;

  typedef struct packed {
    logic [4:0]  d;
  } adc_ctrl_hw2reg_adc_fsm_state_reg_t;

  // Register -> HW type
  typedef struct packed {
    adc_ctrl_reg2hw_intr_state_reg_t intr_state; // [451:451]
    adc_ctrl_reg2hw_intr_enable_reg_t intr_enable; // [450:450]
    adc_ctrl_reg2hw_intr_test_reg_t intr_test; // [449:448]
    adc_ctrl_reg2hw_alert_test_reg_t alert_test; // [447:446]
    adc_ctrl_reg2hw_adc_en_ctl_reg_t adc_en_ctl; // [445:444]
    adc_ctrl_reg2hw_adc_pd_ctl_reg_t adc_pd_ctl; // [443:415]
    adc_ctrl_reg2hw_adc_lp_sample_ctl_reg_t adc_lp_sample_ctl; // [414:407]
    adc_ctrl_reg2hw_adc_sample_ctl_reg_t adc_sample_ctl; // [406:391]
    adc_ctrl_reg2hw_adc_fsm_rst_reg_t adc_fsm_rst; // [390:390]
    adc_ctrl_reg2hw_adc_chn0_filter_ctl_mreg_t [7:0] adc_chn0_filter_ctl; // [389:214]
    adc_ctrl_reg2hw_adc_chn1_filter_ctl_mreg_t [7:0] adc_chn1_filter_ctl; // [213:38]
    adc_ctrl_reg2hw_adc_wakeup_ctl_reg_t adc_wakeup_ctl; // [37:29]
    adc_ctrl_reg2hw_filter_status_reg_t filter_status; // [28:20]
    adc_ctrl_reg2hw_adc_intr_ctl_reg_t adc_intr_ctl; // [19:10]
    adc_ctrl_reg2hw_adc_intr_status_reg_t adc_intr_status; // [9:0]
  } adc_ctrl_reg2hw_t;

  // HW -> register type
  typedef struct packed {
    adc_ctrl_hw2reg_intr_state_reg_t intr_state; // [86:85]
    adc_ctrl_hw2reg_adc_chn_val_mreg_t [1:0] adc_chn_val; // [84:29]
    adc_ctrl_hw2reg_filter_status_reg_t filter_status; // [28:18]
    adc_ctrl_hw2reg_adc_intr_status_reg_t adc_intr_status; // [17:5]
    adc_ctrl_hw2reg_adc_fsm_state_reg_t adc_fsm_state; // [4:0]
  } adc_ctrl_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] ADC_CTRL_INTR_STATE_OFFSET = 7'h 0;
  parameter logic [BlockAw-1:0] ADC_CTRL_INTR_ENABLE_OFFSET = 7'h 4;
  parameter logic [BlockAw-1:0] ADC_CTRL_INTR_TEST_OFFSET = 7'h 8;
  parameter logic [BlockAw-1:0] ADC_CTRL_ALERT_TEST_OFFSET = 7'h c;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_EN_CTL_OFFSET = 7'h 10;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_PD_CTL_OFFSET = 7'h 14;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_LP_SAMPLE_CTL_OFFSET = 7'h 18;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_SAMPLE_CTL_OFFSET = 7'h 1c;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_FSM_RST_OFFSET = 7'h 20;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN0_FILTER_CTL_0_OFFSET = 7'h 24;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN0_FILTER_CTL_1_OFFSET = 7'h 28;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN0_FILTER_CTL_2_OFFSET = 7'h 2c;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN0_FILTER_CTL_3_OFFSET = 7'h 30;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN0_FILTER_CTL_4_OFFSET = 7'h 34;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN0_FILTER_CTL_5_OFFSET = 7'h 38;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN0_FILTER_CTL_6_OFFSET = 7'h 3c;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN0_FILTER_CTL_7_OFFSET = 7'h 40;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN1_FILTER_CTL_0_OFFSET = 7'h 44;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN1_FILTER_CTL_1_OFFSET = 7'h 48;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN1_FILTER_CTL_2_OFFSET = 7'h 4c;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN1_FILTER_CTL_3_OFFSET = 7'h 50;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN1_FILTER_CTL_4_OFFSET = 7'h 54;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN1_FILTER_CTL_5_OFFSET = 7'h 58;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN1_FILTER_CTL_6_OFFSET = 7'h 5c;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN1_FILTER_CTL_7_OFFSET = 7'h 60;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN_VAL_0_OFFSET = 7'h 64;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_CHN_VAL_1_OFFSET = 7'h 68;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_WAKEUP_CTL_OFFSET = 7'h 6c;
  parameter logic [BlockAw-1:0] ADC_CTRL_FILTER_STATUS_OFFSET = 7'h 70;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_INTR_CTL_OFFSET = 7'h 74;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_INTR_STATUS_OFFSET = 7'h 78;
  parameter logic [BlockAw-1:0] ADC_CTRL_ADC_FSM_STATE_OFFSET = 7'h 7c;

  // Reset values for hwext registers and their fields
  parameter logic [0:0] ADC_CTRL_INTR_TEST_RESVAL = 1'h 0;
  parameter logic [0:0] ADC_CTRL_INTR_TEST_MATCH_PENDING_RESVAL = 1'h 0;
  parameter logic [0:0] ADC_CTRL_ALERT_TEST_RESVAL = 1'h 0;
  parameter logic [0:0] ADC_CTRL_ALERT_TEST_FATAL_FAULT_RESVAL = 1'h 0;
  parameter logic [4:0] ADC_CTRL_ADC_FSM_STATE_RESVAL = 5'h 0;
  parameter logic [4:0] ADC_CTRL_ADC_FSM_STATE_STATE_RESVAL = 5'h 0;

  // Register index
  typedef enum int {
    ADC_CTRL_INTR_STATE,
    ADC_CTRL_INTR_ENABLE,
    ADC_CTRL_INTR_TEST,
    ADC_CTRL_ALERT_TEST,
    ADC_CTRL_ADC_EN_CTL,
    ADC_CTRL_ADC_PD_CTL,
    ADC_CTRL_ADC_LP_SAMPLE_CTL,
    ADC_CTRL_ADC_SAMPLE_CTL,
    ADC_CTRL_ADC_FSM_RST,
    ADC_CTRL_ADC_CHN0_FILTER_CTL_0,
    ADC_CTRL_ADC_CHN0_FILTER_CTL_1,
    ADC_CTRL_ADC_CHN0_FILTER_CTL_2,
    ADC_CTRL_ADC_CHN0_FILTER_CTL_3,
    ADC_CTRL_ADC_CHN0_FILTER_CTL_4,
    ADC_CTRL_ADC_CHN0_FILTER_CTL_5,
    ADC_CTRL_ADC_CHN0_FILTER_CTL_6,
    ADC_CTRL_ADC_CHN0_FILTER_CTL_7,
    ADC_CTRL_ADC_CHN1_FILTER_CTL_0,
    ADC_CTRL_ADC_CHN1_FILTER_CTL_1,
    ADC_CTRL_ADC_CHN1_FILTER_CTL_2,
    ADC_CTRL_ADC_CHN1_FILTER_CTL_3,
    ADC_CTRL_ADC_CHN1_FILTER_CTL_4,
    ADC_CTRL_ADC_CHN1_FILTER_CTL_5,
    ADC_CTRL_ADC_CHN1_FILTER_CTL_6,
    ADC_CTRL_ADC_CHN1_FILTER_CTL_7,
    ADC_CTRL_ADC_CHN_VAL_0,
    ADC_CTRL_ADC_CHN_VAL_1,
    ADC_CTRL_ADC_WAKEUP_CTL,
    ADC_CTRL_FILTER_STATUS,
    ADC_CTRL_ADC_INTR_CTL,
    ADC_CTRL_ADC_INTR_STATUS,
    ADC_CTRL_ADC_FSM_STATE
  } adc_ctrl_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] ADC_CTRL_PERMIT [32] = '{
    4'b 0001, // index[ 0] ADC_CTRL_INTR_STATE
    4'b 0001, // index[ 1] ADC_CTRL_INTR_ENABLE
    4'b 0001, // index[ 2] ADC_CTRL_INTR_TEST
    4'b 0001, // index[ 3] ADC_CTRL_ALERT_TEST
    4'b 0001, // index[ 4] ADC_CTRL_ADC_EN_CTL
    4'b 1111, // index[ 5] ADC_CTRL_ADC_PD_CTL
    4'b 0001, // index[ 6] ADC_CTRL_ADC_LP_SAMPLE_CTL
    4'b 0011, // index[ 7] ADC_CTRL_ADC_SAMPLE_CTL
    4'b 0001, // index[ 8] ADC_CTRL_ADC_FSM_RST
    4'b 1111, // index[ 9] ADC_CTRL_ADC_CHN0_FILTER_CTL_0
    4'b 1111, // index[10] ADC_CTRL_ADC_CHN0_FILTER_CTL_1
    4'b 1111, // index[11] ADC_CTRL_ADC_CHN0_FILTER_CTL_2
    4'b 1111, // index[12] ADC_CTRL_ADC_CHN0_FILTER_CTL_3
    4'b 1111, // index[13] ADC_CTRL_ADC_CHN0_FILTER_CTL_4
    4'b 1111, // index[14] ADC_CTRL_ADC_CHN0_FILTER_CTL_5
    4'b 1111, // index[15] ADC_CTRL_ADC_CHN0_FILTER_CTL_6
    4'b 1111, // index[16] ADC_CTRL_ADC_CHN0_FILTER_CTL_7
    4'b 1111, // index[17] ADC_CTRL_ADC_CHN1_FILTER_CTL_0
    4'b 1111, // index[18] ADC_CTRL_ADC_CHN1_FILTER_CTL_1
    4'b 1111, // index[19] ADC_CTRL_ADC_CHN1_FILTER_CTL_2
    4'b 1111, // index[20] ADC_CTRL_ADC_CHN1_FILTER_CTL_3
    4'b 1111, // index[21] ADC_CTRL_ADC_CHN1_FILTER_CTL_4
    4'b 1111, // index[22] ADC_CTRL_ADC_CHN1_FILTER_CTL_5
    4'b 1111, // index[23] ADC_CTRL_ADC_CHN1_FILTER_CTL_6
    4'b 1111, // index[24] ADC_CTRL_ADC_CHN1_FILTER_CTL_7
    4'b 1111, // index[25] ADC_CTRL_ADC_CHN_VAL_0
    4'b 1111, // index[26] ADC_CTRL_ADC_CHN_VAL_1
    4'b 0011, // index[27] ADC_CTRL_ADC_WAKEUP_CTL
    4'b 0011, // index[28] ADC_CTRL_FILTER_STATUS
    4'b 0011, // index[29] ADC_CTRL_ADC_INTR_CTL
    4'b 0011, // index[30] ADC_CTRL_ADC_INTR_STATUS
    4'b 0001  // index[31] ADC_CTRL_ADC_FSM_STATE
  };

endpackage
