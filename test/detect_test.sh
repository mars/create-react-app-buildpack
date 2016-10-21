. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

test_fails_without_package_json() {
  detect
  assertNoAppDetected
}

test_matches_package_json() {
  touch $BUILD_DIR/package.json
  detect
  assertAppDetected create-react-app
}
