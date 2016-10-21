#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
cache_dir=$(sed '/^\#/d' ${BUILDPACK_TEST_RUNNER_HOME}/lib/magic_curl/conf/cache.conf | grep 'cache_dir'  | tail -n 1 | cut -d "=" -f2-)
url="http://repo1.maven.org/maven2/com/force/api/force-wsc/23.0.0/force-wsc-23.0.0.jar"
cached_file="${cache_dir}/repo1.maven.org/maven2/com/force/api/force-wsc/23.0.0/force-wsc-23.0.0.jar"
cached_file_md5="57e2997c35da552ede220f118d1fa941"

successfulCaching()
{
  curl_args=$1
  output_file=$2

  if [ -f ${cached_file} ]; then
    rm ${cached_file}
  fi
  assertFalse "[ -f ${cached_file} ]"

  capture ${BUILDPACK_TEST_RUNNER_HOME}/lib/magic_curl/bin/curl ${curl_args}

  assertTrue "[ -f ${cached_file} ]"
  assertFileMD5 "${cached_file_md5}" ${cached_file}
  assertFileMD5 "${cached_file_md5}" ${output_file}
  assertEquals "" "$(cat ${STD_ERR})"
}

testDownloadToStdOut()
{
  successfulCaching "--silent ${url} --compressed" "${STD_OUT}"
}

testDownloadWithOutputArg_Full()
{
  local_file=${OUTPUT_DIR}/file.output
  successfulCaching "--silent ${url} --output ${local_file}" "${local_file}"
}

testDownloadWithOutputArg_Short()
{
  local_file=${OUTPUT_DIR}/file.output
  successfulCaching "--silent ${url} -o ${local_file}" "${local_file}"
}

testDownloadWithOutputArgFollowedByOtherArgs()
{
  local_file=${OUTPUT_DIR}/file.output
  successfulCaching "--silent ${url} --output ${local_file} --compressed" "${local_file}"
}

testDownloadWithRemoteNameArg_Full()
{
  local_file=${OUTPUT_DIR}/force-wsc-23.0.0.jar
  
  pwd="$(pwd)"
  cd ${OUTPUT_DIR}
  successfulCaching "--silent --remote-name ${url}" "${local_file}"
  cd ${pwd}
}

testDownloadWithRemoteNameArg_Short()
{
  local_file=${OUTPUT_DIR}/force-wsc-23.0.0.jar
  
  pwd="$(pwd)"
  cd ${OUTPUT_DIR}
  successfulCaching "--silent -O ${url}" "${local_file}"
  cd ${pwd}
}

testDownloadWithRemoteNameArgFollowedByOtherArgs()
{
  local_file=${OUTPUT_DIR}/force-wsc-23.0.0.jar
  
  pwd="$(pwd)"
  cd ${OUTPUT_DIR}
  successfulCaching "--silent ${url}  --remote-name --compressed" "${local_file}"
  cd ${pwd}
}

testNoArgs()
{
  capture ${BUILDPACK_TEST_RUNNER_HOME}/lib/magic_curl/bin/curl
  
  assertEquals "" "$(cat ${STD_OUT})"
  assertEquals "curl: try 'curl --help' or 'curl --manual' for more information" "$(cat ${STD_ERR})"
  assertEquals "2" "${rtrn}"
}

testNoUrl()
{
  capture ${BUILDPACK_TEST_RUNNER_HOME}/lib/magic_curl/bin/curl --silent
  
  assertEquals "" "$(cat ${STD_OUT})"
  assertContains "curl: no URL specified!" "$(cat ${STD_ERR})"
  assertEquals "2" "${rtrn}"
}

test403WithFail()
{
  capture ${BUILDPACK_TEST_RUNNER_HOME}/lib/magic_curl/bin/curl http://s3.amazonaws.com/heroku-jvm-langpack-scala/sbt-xxxx.boot.properties --fail   
  
  assertEquals "" "$(cat ${STD_OUT})"
  assertContains "curl: (22) The requested URL returned error: 403" "$(cat ${STD_ERR})"
  assertEquals "22" "${rtrn}"
}

