. ${BUILDPACK_HOME}/lib/test_utils.sh

test_react_app_0_6_1() {
  cp -r $BUILDPACK_HOME/test/fixtures/react-app-0.6.1/* $BUILD_DIR
  compile
  assertEquals "Expected captured exit code to be 0; was <${RETURN}>" "0" "${RETURN}"
  assertTrue 'missing static.json' "[ -f $BUILD_DIR/static.json ]"
  assertTrue 'missing index.html' "[ -f $BUILD_DIR/build/index.html ]"
  assertTrue 'missing JS bundle' "[ -f $BUILD_DIR/build/static/js/main.*.js ]"
  assertTrue 'missing CSS bundle' "[ -f $BUILD_DIR/build/static/css/main.*.css ]"
}
