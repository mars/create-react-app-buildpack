#!/bin/sh

oneTimeSetUp()
{
   TEST_SUITE_CACHE="$(mktemp -d ${SHUNIT_TMPDIR}/test_suite_cache.XXXX)"
}

oneTimeTearDown()
{
  rm -rf ${TEST_SUITE_CACHE}
}

# override these hooks in test files
beforeSetUp()
{
  :
}

afterSetUp()
{
  :
}

beforeTearDown()
{
  :
}

afterTearDown()
{
  :
}

setUp()
{
  beforeSetUp
  OUTPUT_DIR="$(mktemp -d ${SHUNIT_TMPDIR}/output.XXXX)"
  STD_OUT_FIFO="${SHUNIT_TMPDIR:-/tmp}/out.$$"
  STD_OUT="${OUTPUT_DIR}/stdout"
  STD_ERR_FIFO="${SHUNIT_TMPDIR:-/tmp}/err.$$"
  STD_ERR="${OUTPUT_DIR}/stderr"
  BUILD_DIR="${OUTPUT_DIR}/build"
  CACHE_DIR="${OUTPUT_DIR}/cache"
  ENV_DIR="${OUTPUT_DIR}/env"
  mkdir -p ${OUTPUT_DIR}
  mkdir -p ${BUILD_DIR}
  mkdir -p ${CACHE_DIR}
  mkdir -p ${ENV_DIR}
  afterSetUp
}

tearDown()
{
  beforeTearDown
  rm -rf ${OUTPUT_DIR}
  afterTearDown
}

capture()
{
  resetCapture
  
  LAST_COMMAND="$@"

  #$@ >${STD_OUT} 2>${STD_ERR}
  mkfifo "$STD_OUT_FIFO" "$STD_ERR_FIFO"
  trap 'rm "$STD_OUT_FIFO" "$STD_ERR_FIFO"' EXIT
  tee "$STD_OUT" < "$STD_OUT_FIFO" &
  tee "$STD_ERR" < "$STD_ERR_FIFO" >&2 &
  $@ >"$STD_OUT_FIFO" 2>"$STD_ERR_FIFO"

  RETURN=$?
  rtrn=${RETURN} # deprecated
}

resetCapture()
{
  if [ -f ${STD_OUT} ]; then
    rm ${STD_OUT}
  fi

  if [ -f ${STD_ERR} ]; then
    rm ${STD_ERR}
  fi
  
  if [ ${STD_OUT_FIFO} ] && [ -e ${STD_OUT_FIFO} ]; then
    rm ${STD_OUT_FIFO}
  fi

  if [ ${STD_ERR_FIFO} ] && [ -e ${STD_ERR_FIFO} ]; then
    rm ${STD_ERR_FIFO}
  fi

  unset LAST_COMMAND
  unset RETURN
  unset rtrn # deprecated
}

detect()
{
  capture ${BUILDPACK_HOME}/bin/detect ${BUILD_DIR}
}

compile()
{
  capture ${BUILDPACK_HOME}/bin/compile ${BUILD_DIR} ${CACHE_DIR} ${ENV_DIR}
}

release()
{
  capture ${BUILDPACK_HOME}/bin/release ${BUILD_DIR}
}

assertCapturedEquals()
{
  assertEquals "$@" "$(cat ${STD_OUT})"
}

assertCapturedNotEquals()
{
  assertNotEquals "$@" "$(cat ${STD_OUT})"
}

assertCaptured()
{
  assertFileContains "$@" "${STD_OUT}"
}

assertNotCaptured()
{
  assertFileNotContains "$@" "${STD_OUT}"
}

assertCapturedSuccess()
{
  assertEquals "Expected captured exit code to be 0; was <${RETURN}>" "0" "${RETURN}"
  assertEquals "Expected STD_ERR to be empty; was <$(cat ${STD_ERR})>" "" "$(cat ${STD_ERR})"
}

# assertCapturedError [[expectedErrorCode] expectedErrorMsg]
assertCapturedError()
{
  if [ $# -gt 1 ]; then
    expectedErrorCode=${1}
    shift
  fi

  expectedErrorMsg=${1:-""}

  if [ -z ${expectedErrorCode} ]; then
    assertTrue "Expected captured exit code to be greater than 0; was <${RETURN}>" "[ ${RETURN} -gt 0 ]"
  else
    assertTrue "Expected captured exit code to be <${expectedErrorCode}>; was <${RETURN}>" "[ ${RETURN} -eq ${expectedErrorCode} ]"
  fi

  assertFileContains "Expected STD_OUT to contain error <${expectedErrorMsg}>" "${expectedErrorMsg}" "${STD_OUT}"
  assertEquals       "STD_ERR should always be empty" "" "$(cat ${STD_ERR})"
}

assertAppDetected()
{
  expectedAppType=${1?"Must provide app type"}

  assertCapturedSuccess
  assertEquals "${expectedAppType}" "$(cat ${STD_OUT})"
}

assertNoAppDetected()
{
  assertEquals "1" "${RETURN}"
  assertEquals "no" "$(cat ${STD_OUT})"
  assertEquals "" "$(cat ${STD_ERR})"
}

_assertContains()
{
  if [ 5 -eq $# ]; then
    msg=$1
    shift
  elif [ ! 4 -eq $# ]; then
    fail "Expected 4 or 5 parameters; Receieved $# parameters"
  fi

  needle=$1
  haystack=$2
  expectation=$3
  haystack_type=$4
  
  case "${haystack_type}" in
    "file") grep -q -F -e "${needle}" ${haystack} ;;
    "text") echo "${haystack}" | grep -q -F -e "${needle}" ;;
  esac

  if [ "${expectation}" != "$?" ]; then
    case "${expectation}" in
      0) default_msg="Expected <${haystack}> to contain <${needle}>" ;;
      1) default_msg="Did not expect <${haystack}> to contain <${needle}>" ;;
    esac

    fail "${msg:-${default_msg}}"
  fi   
}

assertContains()
{
  _assertContains "$@" 0 "text"
}

assertNotContains()
{
  _assertContains "$@" 1 "text"
}

assertFileContains()
{
  _assertContains "$@" 0 "file"
}

assertFileNotContains()
{
  _assertContains "$@" 1 "file"
}

command_exists () {
    type "$1" > /dev/null 2>&1 ;
}

assertFileMD5()
{
  expectedHash=$1
  filename=$2

  if command_exists "md5sum"; then
    md5_cmd="md5sum ${filename}"
    expected_md5_cmd_output="${expectedHash}  ${filename}"
  elif command_exists "md5"; then
    md5_cmd="md5 ${filename}"
    expected_md5_cmd_output="MD5 (${filename}) = ${expectedHash}"
  else
    fail "no suitable MD5 hashing command found on this system"
  fi

  assertEquals "${expected_md5_cmd_output}" "`${md5_cmd}`"
}
