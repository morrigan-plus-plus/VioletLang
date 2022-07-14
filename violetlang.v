import os
import term

import scanner

fn usage(program_name string) {
	eprintln("USAGE: " + term.yellow("$program_name [arguments] <input file>.vl"))
	eprintln("ARGUMENTS:")
	eprintln(term.bright_blue("\t-h, --help\tPrint this message and exit with exit code 0."))
	eprintln(term.bright_blue("\t-v, --verbose\tIncrease the verbosity of the output. (use -vv / --vverbose for an even higher level)"))
}

fn main() {
	program_name := os.base(os.args[0])
	term.clear()

	if os.args.len < 2 {
		usage(program_name)
		exit(1)
	}

	mut input_file := ""
	mut verbosity := 0

	for arg in os.args[1..] {
		if arg.starts_with("-") {
			match arg {
				"-h", "--help" {
					usage(program_name)
					exit(0)
				}
				"-v", "--verbose" {
					verbosity = 1
				} 
				"-vv", "--vverbose" {
					verbosity = 2	
				} else {
					usage(program_name)
					println(term.bright_red("\nUnknown argument: `$arg`."))
					exit(1)
				}
			}
		} else {
			if input_file != "" {
				eprintln(term.bright_red("Only one input file can be provided."))
				exit(1)
			}

			input_file = arg
		}
	}

	if verbosity > 0 { println("> Checking status of file `$input_file`.") }


	if input_file == "" {
		eprintln(term.bright_red("No input file was provided."))
		exit(1)
	}
	
	if verbosity > 1 { println(">> Checking if file `$input_file` exists.") }

	if !os.exists(input_file) {
		eprintln(term.bright_red("The file `$input_file` does not exist."))
		exit(1)
	}
	
	if verbosity > 1 { println(term.bright_green(">> File `$input_file` exists.")) }
	if verbosity > 1 { println(">> Checking if file `$input_file` is a file or a directory.") }

	if os.is_dir(input_file) {
		eprintln(term.bright_red("`$input_file` is a directory."))
		exit(1)
	}

	if verbosity > 1 { println(term.bright_green(">> `$input_file` is a file, not a directory.")) }
	if verbosity > 0 { println(term.bright_green("> File is present and ready for reading.")) }

	mut scanner := scanner.scanner_from_file(input_file, verbosity) or {
		println(term.bright_red("Error reading file `$input_file`."))
		exit(1)
	}

	scanner.scan()

	println(scanner)
}