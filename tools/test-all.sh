# Executes the entire test suite for java semantics - all programs in ../programs directory.
# Run the script from semantics directory.

START=$(date +%s)

perl ../tools/tester.pl -d ../programs/01_smoke_tests/tests -f "--parser=\"java -cp JavaParser.jar ro.uaic.info.fmse.parser.Main\" --no-color --output-mode=none" -n 01_smoke_tests -timeout 25
perl ../tools/tester.pl -d ../programs/02_literals/tests -f "--parser=\"java -cp JavaParser.jar ro.uaic.info.fmse.parser.Main\" --no-color --output-mode=none" -n 02_literals -timeout 25
perl ../tools/tester.pl -d ../programs/03_syntax_samples/tests -f "--parser=\"java -cp JavaParser.jar ro.uaic.info.fmse.parser.Main\" --no-color --output-mode=none" -n 03_syntax_samples -timeout 25
perl ../tools/tester.pl -d ../programs/04_operators/tests -f "--parser=\"java -cp JavaParser.jar ro.uaic.info.fmse.parser.Main\" --no-color --output-mode=none" -n 04_operators -timeout 25
perl ../tools/tester.pl -d ../programs/05_statements/tests -f "--parser=\"java -cp JavaParser.jar ro.uaic.info.fmse.parser.Main\" --no-color --output-mode=none" -n 05_statements -timeout 25
perl ../tools/tester.pl -d ../programs/06_stat_stack/tests -f "--parser=\"java -cp JavaParser.jar ro.uaic.info.fmse.parser.Main\" --no-color --output-mode=none" -n 06_stat_stack -timeout 25
perl ../tools/tester.pl -d ../programs/07_stat_switch/tests -f "--parser=\"java -cp JavaParser.jar ro.uaic.info.fmse.parser.Main\" --no-color --output-mode=none" -n 07_stat_switch -timeout 25
perl ../tools/tester.pl -d ../programs/08_sorting/tests -f "--parser=\"java -cp JavaParser.jar ro.uaic.info.fmse.parser.Main\" --no-color --output-mode=none" -n 08_sorting -timeout 25
perl ../tools/tester.pl -d ../programs/09_diverse/tests -f "--parser=\"java -cp JavaParser.jar ro.uaic.info.fmse.parser.Main\" --no-color --output-mode=none" -n 09_diverse -timeout 25
perl ../tools/tester.pl -d ../programs/10_exceptions/tests -f "--parser=\"java -cp JavaParser.jar ro.uaic.info.fmse.parser.Main\" --no-color --output-mode=none" -n 10_exceptions -timeout 25
perl ../tools/tester.pl -d ../programs/11_kool_smoke_tests/tests -f "--parser=\"java -cp JavaParser.jar ro.uaic.info.fmse.parser.Main\" --no-color --output-mode=none" -n 11_kool_smoke_tests -timeout 25
perl ../tools/tester.pl -d ../programs/12_kool/tests -f "--parser=\"java -cp JavaParser.jar ro.uaic.info.fmse.parser.Main\" --no-color --output-mode=none" -n 12_kool -timeout 25

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
  > test-all-results.xml

END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds"
