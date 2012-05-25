# Removes all temporary files created by test-all.sh, in all program directories.

./../tools/clean-dir.sh ../programs/01_smoke_tests
./../tools/clean-dir.sh ../programs/02_literals
./../tools/clean-dir.sh ../programs/03_syntax_samples
./../tools/clean-dir.sh ../programs/04_operators
./../tools/clean-dir.sh ../programs/05_statements
./../tools/clean-dir.sh ../programs/06_stat_stack
./../tools/clean-dir.sh ../programs/07_stat_switch
./../tools/clean-dir.sh ../programs/08_sorting
./../tools/clean-dir.sh ../programs/09_diverse
./../tools/clean-dir.sh ../programs/10_exceptions
./../tools/clean-dir.sh ../programs/11_kool_smoke_tests
./../tools/clean-dir.sh ../programs/12_kool

# for 13_thread_term don't remove .out files
rm -f ../programs/13_thread_term/tests/*.diff
rm -f ../programs/13_thread_term/tests/*.stdout
rm -f ../programs/13_thread_term/tests/*.stderr
rm -f ../programs/13_thread_term/tests/*.xml

./../tools/clean-dir.sh ../programs/14_java_api_core
