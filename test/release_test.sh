#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

test_captured_from_last_buildpack()
{
  expected_release_output='xyz'
  echo $expected_release_output > $BUILD_DIR/last_pack_release.out

  capture ${BUILDPACK_HOME}/bin/release ${BUILD_DIR}
  assertEquals 0 ${rtrn}
  assertEquals "${expected_release_output}" "$(cat ${STD_OUT})"
  assertEquals "" "$(cat ${STD_ERR})"
}
