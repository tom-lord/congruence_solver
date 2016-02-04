#!/usr/bin/env ruby
require 'congruence_solver'
require "polynomial_interpreter"

SOLVE_CONGRUENCE_BENCH_FILE = "../bench/solve_congruence_bm.rb"

if ARGV.pop == "bench"
  require_relative SOLVE_CONGRUENCE_BENCH_FILE
  exit(0)
end

puts "Congruence to solve:"

begin
  coeffs, mod = PolynomialInterpreter.read_congruence(STDIN.gets)
rescue PolynomialInterpreter => e
  STDERR.puts e.message
  exit(1)
end

solutions = CongruenceSolver.lift(coeffs, mod).sort

if solutions.empty?
  puts "No solution."
else
  puts "Solutions:"
  solutions.each_with_index {|sol, i| puts "(#{i}) #{sol}"}
end
