# Executes the entire test suite for java semantics - all programs in ../programs directory.
# Run the script from semantics directory.

START=$(date +%s)

./../tools/test-jdk-comp-dir.sh ../programs/01_smoke_tests
./../tools/test-jdk-comp-dir.sh ../programs/01_smoke_tests
./../tools/test-jdk-comp-dir.sh ../programs/02_literals
./../tools/test-jdk-comp-dir.sh ../programs/03_syntax_samples
./../tools/test-jdk-comp-dir.sh ../programs/04_operators
./../tools/test-jdk-comp-dir.sh ../programs/05_statements
./../tools/test-jdk-comp-dir.sh ../programs/06_stat_stack
./../tools/test-jdk-comp-dir.sh ../programs/07_stat_switch
./../tools/test-jdk-comp-dir.sh ../programs/08_sorting
./../tools/test-jdk-comp-dir.sh ../programs/09_diverse
./../tools/test-jdk-comp-dir.sh ../programs/10_exceptions
./../tools/test-jdk-comp-dir.sh ../programs/11_kool_smoke_tests
./../tools/test-jdk-comp-dir.sh ../programs/12_kool
./../tools/test-non-jdk-comp-dir.sh ../programs/13_thread_term
./../tools/test-jdk-comp-dir.sh ../programs/14_java_api_core

cat \
  ../programs/01_smoke_tests/tests/krun-results.xml \
  ../programs/02_literals/tests/krun-results.xml \
  ../programs/03_syntax_samples/tests/krun-results.xml \
  ../programs/04_operators/tests/krun-results.xml \
  ../programs/05_statements/tests/krun-results.xml \
  ../programs/06_stat_stack/tests/krun-results.xml \
  ../programs/07_stat_switch/tests/krun-results.xml \
  ../programs/08_sorting/tests/krun-results.xml \
  ../programs/09_diverse/tests/krun-results.xml \
  ../programs/10_exceptions/tests/krun-results.xml \
  ../programs/11_kool_smoke_tests/tests/krun-results.xml \
  ../programs/12_kool/tests/krun-results.xml \
  ../programs/13_thread_term/tests/krun-results.xml \
  ../programs/14_java_api_core/tests/krun-results.xml \
  > test-all-results.xml

END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds"
