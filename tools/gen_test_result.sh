#/usr/bin/sh

prove -r --timer --formatter=TAP::Formatter::JUnit -l t > jenkins/test_results.xml
