#!/usr/bin/env bats

BATS_TMPDIR=${BATS_TMPDIR:-/tmp}     # set default if sourcing from cli
REPO_PATH=$(mktemp -d "${BATS_TMPDIR}/gittest.XXXXXX")

testCommit() {
  filename=$1
  (cd "$REPO_PATH" && git add "$filename" && git commit -m 'test commit')
}

setup() {
  repo="$BATS_TEST_DIRNAME/test_repo.bundle"
  git clone "$repo" "$REPO_PATH"
}

teardown() {
  rm -fr "${REPO_PATH}"
}

addFileWithNoSecrets() {
  local filename="$REPO_PATH/plainfile.md"

  touch "$filename"
  echo "Just a plain old file" >> "$filename"
  testCommit "$filename"
}

addFileWithAwsSecrets() {
  local secrets_file="$REPO_PATH/secretsfile.md"

  cat > "$secrets_file" <<END
SHHHH... Secrets in this file
aws_secret_access_key = WT8ftNba7siVx5UOoGzJSyd82uNCZAC8LCllzcWp
END
  testCommit "$secrets_file"
}

addFileWithAwsAccessKey() {
  local secrets_file="$REPO_PATH/accessfile.md"
  cat > "$secrets_file" <<END
SHHHH... Secrets in this file
AWS_ACCESS_KEY_ID: AKIAJLLCKKYFEWP5MWXA
END
  testCommit "$secrets_file"
}

addFileWithSlackAPIToken() {
  local secrets_file="$REPO_PATH/slacktokenfile.md"

  cat > "$secrets_file" <<END
SHHHH... Secrets in this file
slack_api_token=xoxb-333649436676-799261852869-clFJVVIaoJahpORboa3Ba2al
END
  testCommit "$secrets_file"
}

addFileWithIPv4() {
  local secrets_file="$REPO_PATH/ipv4file.md"

  cat > "$secrets_file" <<END
SHHHH... Secrets in this file
Host: 127.0.0.1
END
  testCommit "$secrets_file"
}

yamlTest() {
  local secrets_file="$REPO_PATH/cloudgov.yml"
  cat > "$secrets_file" <<END
# Credentials
$1
END
  testCommit "$secrets_file"
}

### TESTS

@test "leak prevention allows plain text" {
  run addFileWithNoSecrets
  [ $status -eq 0 ]
  # echo "$output"
  # echo "$output" | grep "No leaks detected in staged changes"
}

@test "leak prevention catches aws secrets in test repo" {
  run addFileWithAwsSecrets
  [ "$status" -eq 1 ]
}

@test "leak prevention catches aws accesskey in test repo" {
  run addFileWithAwsAccessKey
  [ "$status" -eq 1 ]
}

@test "leak prevention catches aws accounts in test repo" {
  skip # not implemented
  run addFileWithAwsAccounts
  [ "$status" -eq 1 ]
}

@test "leak prevention catches Slack api token in test repo" {
  run addFileWithSlackAPIToken
  [ "$status" -eq 1 ]
}

@test "leak prevention catches IPv4 address in test repo" {
  run addFileWithIPv4
  [ "$status" -eq 1 ]
}

@test "it catches yaml with deploy password" {
  run yamlTest "deploy-password: ohSh.aiNgai%noh4us%ie5nee.nah1ee"
  [ "$status" -eq 1 ]
}

@test "it catches yaml with Slack webhook" {
  run yamlTest "slack-webhook-url: https://hooks.slack.com/services/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"
  [ "$status" -eq 1 ]
}

@test "it catches yaml with encryption key" {
  run yamlTest "development-enc-key: aich3thei2ieCai0choyohg9Iephoh8I"
  [ "$status" -eq 1 ]
}

@test "it catches yaml with auth pass" {
  run yamlTest "development-auth-pass: woothothae5IezaiD8gu0eiweKui4sah"
  [ "$status" -eq 1 ]
}
