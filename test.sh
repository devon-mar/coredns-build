#!/bin/bash

set -x

TEST_FQDN="_acme-challenge.test1.example.com"
TEST_CONTENT="hello world!"
TEST_USER="user1"

curl -X PUT -d "fqdn=$TEST_FQDN&content=$TEST_CONTENT" -H "X-Forwarded-User: $TEST_USER" localhost:8080/update

error_count=0

output=$(dig +noall +answer +norec @localhost -p 5353 -t TXT $TEST_FQDN)
expected="_acme-challenge.test1.example.com. 0 IN	TXT	\"hello world!\""
if [ "$output" != "$expected" ]; then
  echo "Actual: $output"
  echo "Expected: $expected"
  error_count=$((error_count + 1))
fi

output=$(dig +noall +answer +norec @localhost -p 5353 -t A "example.com")
expected="example.com.		300	IN	A	192.0.2.1"
if [ "$output" != "$expected" ]; then
  echo "Actual: $output"
  echo "Expected: $expected"
  error_count=$((error_count + 1))
fi

if [ "$error_count" -eq 0 ]; then
  echo -e '\033[32mAll tests passed!\033[0m'
fi

exit $error_count
