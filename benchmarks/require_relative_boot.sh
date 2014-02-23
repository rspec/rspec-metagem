ruby -v

echo "3 runs without require_relative, booting 100 times each run:"
for i in {1..3}; do
  time (for i in {1..100}; do ruby -Ilib:../rspec-support/lib -e "require 'rspec/core'"; done)
done

echo
echo "3 runs with require_relative, booting 100 times each run:"
export REQUIRE_RELATIVE=1
for i in {1..3}; do
  time (for i in {1..100}; do ruby -Ilib:../rspec-support/lib -e "require 'rspec/core'"; done)
done

: <<'result_comment'
ruby 2.1.0p0 (2013-12-25 revision 44422) [x86_64-darwin12.0]
3 runs without require_relative, booting 100 times each run:

real  0m8.152s
user  0m6.783s
sys 0m1.149s

real  0m8.023s
user  0m6.689s
sys 0m1.133s

real  0m8.024s
user  0m6.697s
sys 0m1.131s

3 runs with require_relative, booting 100 times each run:

real  0m7.991s
user  0m6.666s
sys 0m1.118s

real  0m8.020s
user  0m6.686s
sys 0m1.128s

real  0m7.983s
user  0m6.651s
sys 0m1.121s

ruby 2.0.0p247 (2013-06-27 revision 41674) [x86_64-darwin12.4.0]
3 runs without require_relative, booting 100 times each run:

real  0m7.241s
user  0m6.159s
sys 0m0.879s

real  0m7.346s
user  0m6.261s
sys 0m0.901s

real  0m7.218s
user  0m6.157s
sys 0m0.881s

3 runs with require_relative, booting 100 times each run:

real  0m7.224s
user  0m6.165s
sys 0m0.879s

real  0m7.235s
user  0m6.172s
sys 0m0.882s

real  0m7.253s
user  0m6.193s
sys 0m0.887s

ruby 1.9.3p448 (2013-06-27 revision 41675) [x86_64-darwin12.4.0]
3 runs without require_relative, booting 100 times each run:

real  0m7.331s
user  0m6.328s
sys 0m0.831s

real  0m7.026s
user  0m6.073s
sys 0m0.792s

real  0m7.128s
user  0m6.159s
sys 0m0.811s

3 runs with require_relative, booting 100 times each run:

real  0m8.494s
user  0m7.318s
sys 0m0.962s

real  0m7.074s
user  0m6.116s
sys 0m0.793s

real  0m6.997s
user  0m6.038s
sys 0m0.791s

ruby 1.9.2p320 (2012-04-20 revision 35421) [x86_64-darwin12.4.0]
3 runs without require_relative, booting 100 times each run:

real  0m9.484s
user  0m6.893s
sys 0m2.408s

real  0m9.578s
user  0m6.971s
sys 0m2.435s

real  0m9.451s
user  0m6.890s
sys 0m2.395s

3 runs with require_relative, booting 100 times each run:

real  0m9.480s
user  0m6.917s
sys 0m2.397s

real  0m9.586s
user  0m6.999s
sys 0m2.418s

real  0m9.523s
user  0m6.949s
sys 0m2.404s

result_comment
