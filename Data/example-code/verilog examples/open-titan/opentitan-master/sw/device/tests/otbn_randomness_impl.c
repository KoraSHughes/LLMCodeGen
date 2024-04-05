// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/tests/otbn_randomness_impl.h"

#include "sw/device/lib/dif/dif_base.h"
#include "sw/device/lib/dif/dif_otbn.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/otbn_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"

OTBN_DECLARE_APP_SYMBOLS(randomness);
OTBN_DECLARE_SYMBOL_ADDR(randomness, iterations);
OTBN_DECLARE_SYMBOL_ADDR(randomness, rv);
OTBN_DECLARE_SYMBOL_ADDR(randomness, fail_idx);
OTBN_DECLARE_SYMBOL_ADDR(randomness, rnd_out);
OTBN_DECLARE_SYMBOL_ADDR(randomness, urnd_out);

static const otbn_app_t kOtbnAppRandomnessApp = OTBN_APP_T_INIT(randomness);
static const otbn_addr_t kVarIters = OTBN_ADDR_T_INIT(randomness, iterations);
static const otbn_addr_t kVarRv = OTBN_ADDR_T_INIT(randomness, rv);
static const otbn_addr_t kVarFailIdx = OTBN_ADDR_T_INIT(randomness, fail_idx);
static const otbn_addr_t kVarRndOut = OTBN_ADDR_T_INIT(randomness, rnd_out);
static const otbn_addr_t kVarUrndOut = OTBN_ADDR_T_INIT(randomness, urnd_out);

/**
 * LOG_INFO with a 256b unsigned integer as hexadecimal number with a prefix.
 */
static void print_uint256(dif_otbn_t *otbn, const otbn_addr_t var,
                          const char *prefix) {
  uint32_t data[32 / sizeof(uint32_t)];
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, /*len_bytes=*/32, var, &data));
  LOG_INFO("%s0x%08x%08x%08x%08x%08x%08x%08x%08x", prefix, data[7], data[6],
           data[5], data[4], data[3], data[2], data[1], data[0]);
}

void otbn_randomness_test_start(dif_otbn_t *otbn, uint32_t iters) {
  otbn_randomness_test_prepare(otbn, iters);
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
}

void otbn_randomness_test_prepare(dif_otbn_t *otbn, uint32_t iters) {
  // Reset the `kVarRv` value to ensure the result loaded by
  // `otbn_randomness_test_end()` is the one generated by OTBN.
  uint32_t rv = UINT32_MAX;
  CHECK_STATUS_OK(
      otbn_testutils_write_data(otbn, sizeof(uint32_t), &rv, kVarRv));
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kOtbnAppRandomnessApp));
  CHECK_STATUS_OK(
      otbn_testutils_write_data(otbn, sizeof(uint32_t), &iters, kVarIters));
}

bool otbn_randomness_test_end(dif_otbn_t *otbn, bool skip_otbn_done_check) {
  if (!skip_otbn_done_check) {
    CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));
  }
  uint32_t rv;
  CHECK_STATUS_OK(otbn_testutils_read_data(otbn, /*len_bytes=*/4, kVarRv, &rv));
  if (rv != 0) {
    uint32_t fail_idx;
    CHECK_STATUS_OK(otbn_testutils_read_data(otbn, /*len_bytes=*/4, kVarFailIdx,
                                             &fail_idx));
    LOG_ERROR("ERROR: Test with index %d failed.", fail_idx);
    return false;
  }
  return true;
}

void otbn_randomness_test_log_results(dif_otbn_t *otbn) {
  print_uint256(otbn, kVarRndOut, "rnd = ");
  print_uint256(otbn, kVarUrndOut, "urnd = ");
}