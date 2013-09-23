#!/bin/bash
# set -x

# This list is from https://charlie.bz/blog/things-that-clear-rubys-method-cache

IGNORE_FILE=/tmp/cache_busters_ignore
cat ignores | ruby -ne 'puts $_.split(/\s+###/)[0]' > $IGNORE_FILE

egrep 'def [a-z]*\..*' -R lib | grep -v "def self" | grep -v -f $IGNORE_FILE
grep undef -R lib | grep -v -f $IGNORE_FILE
grep alias_method -R lib
grep remove_method -R lib | grep -v -f $IGNORE_FILE
grep const_set -R lib | grep -v -f $IGNORE_FILE
grep remove_const -R lib | grep -v -f $IGNORE_FILE
egrep '\bextend\b' -R lib | grep -v -f $IGNORE_FILE
grep 'Class.new' -R lib | grep -v -f $IGNORE_FILE
grep private_constant -R lib | grep -v -f $IGNORE_FILE
grep public_constant -R lib | grep -v -f $IGNORE_FILE
grep "Marshal.load" -R lib | grep -v -f $IGNORE_FILE
grep "OpenStruct.new" -R lib | grep -v -f $IGNORE_FILE

