. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

test_fails_without_package_json() {
  detect
  assertCapturedError 1 'no'
}

test_matches_package_json() {
  touch $BUILD_DIR/package.json
  detect
  assertCapturedSuccess
}
