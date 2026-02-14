# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_espup_global_optspecs
	string join \n h/help V/version
end

function __fish_espup_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_espup_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_espup_using_subcommand
	set -l cmd (__fish_espup_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c espup -n "__fish_espup_needs_command" -s h -l help -d 'Print help'
complete -c espup -n "__fish_espup_needs_command" -s V -l version -d 'Print version'
complete -c espup -n "__fish_espup_needs_command" -f -a "completions" -d 'Generate completions for the given shell'
complete -c espup -n "__fish_espup_needs_command" -f -a "install" -d 'Installs Espressif Rust ecosystem'
complete -c espup -n "__fish_espup_needs_command" -f -a "uninstall" -d 'Uninstalls Espressif Rust ecosystem'
complete -c espup -n "__fish_espup_needs_command" -f -a "update" -d 'Updates Xtensa Rust toolchain'
complete -c espup -n "__fish_espup_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c espup -n "__fish_espup_using_subcommand completions" -s l -l log-level -d 'Verbosity level of the logs' -r -f -a "debug\t''
info\t''
warn\t''
error\t''"
complete -c espup -n "__fish_espup_using_subcommand completions" -s h -l help -d 'Print help'
complete -c espup -n "__fish_espup_using_subcommand install" -s d -l default-host -d 'Target triple of the host' -r -f -a "x86_64-unknown-linux-gnu\t''
aarch64-unknown-linux-gnu\t''
x86_64-pc-windows-msvc\t''
x86_64-pc-windows-gnu\t''
x86_64-apple-darwin\t''
aarch64-apple-darwin\t''"
complete -c espup -n "__fish_espup_using_subcommand install" -s f -l export-file -d 'Relative or full path for the export file that will be generated. If no path is provided, the file will be generated under home directory (https://docs.rs/dirs/latest/dirs/fn.home_dir.html)' -r -F
complete -c espup -n "__fish_espup_using_subcommand install" -s l -l log-level -d 'Verbosity level of the logs' -r -f -a "debug\t''
info\t''
warn\t''
error\t''"
complete -c espup -n "__fish_espup_using_subcommand install" -s a -l name -d 'Xtensa Rust toolchain name' -r
complete -c espup -n "__fish_espup_using_subcommand install" -s b -l stable-version -d 'Stable Rust toolchain version' -r
complete -c espup -n "__fish_espup_using_subcommand install" -s t -l targets -d 'Comma or space separated list of targets [esp32,esp32c2,esp32c3,esp32c6,esp32h2,esp32s2,esp32s3,esp32p4,all]' -r
complete -c espup -n "__fish_espup_using_subcommand install" -s v -l toolchain-version -d 'Xtensa Rust toolchain version' -r
complete -c espup -n "__fish_espup_using_subcommand install" -s c -l crosstool-toolchain-version -d 'Crosstool-NG toolchain version, e.g. (14.2.0_20241119)' -r
complete -c espup -n "__fish_espup_using_subcommand install" -s r -l esp-riscv-gcc -d 'Install Espressif RISC-V toolchain built with croostool-ng'
complete -c espup -n "__fish_espup_using_subcommand install" -s e -l extended-llvm -d 'Extends the LLVM installation'
complete -c espup -n "__fish_espup_using_subcommand install" -s k -l skip-version-parse -d 'Skips parsing Xtensa Rust version'
complete -c espup -n "__fish_espup_using_subcommand install" -s s -l std -d 'Only install toolchains required for STD applications'
complete -c espup -n "__fish_espup_using_subcommand install" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c espup -n "__fish_espup_using_subcommand uninstall" -s l -l log-level -d 'Verbosity level of the logs' -r -f -a "debug\t''
info\t''
warn\t''
error\t''"
complete -c espup -n "__fish_espup_using_subcommand uninstall" -s a -l name -d 'Xtensa Rust toolchain name' -r
complete -c espup -n "__fish_espup_using_subcommand uninstall" -s c -l crosstool-toolchain-version -d 'GCC toolchain version' -r
complete -c espup -n "__fish_espup_using_subcommand uninstall" -s h -l help -d 'Print help'
complete -c espup -n "__fish_espup_using_subcommand update" -s d -l default-host -d 'Target triple of the host' -r -f -a "x86_64-unknown-linux-gnu\t''
aarch64-unknown-linux-gnu\t''
x86_64-pc-windows-msvc\t''
x86_64-pc-windows-gnu\t''
x86_64-apple-darwin\t''
aarch64-apple-darwin\t''"
complete -c espup -n "__fish_espup_using_subcommand update" -s f -l export-file -d 'Relative or full path for the export file that will be generated. If no path is provided, the file will be generated under home directory (https://docs.rs/dirs/latest/dirs/fn.home_dir.html)' -r -F
complete -c espup -n "__fish_espup_using_subcommand update" -s l -l log-level -d 'Verbosity level of the logs' -r -f -a "debug\t''
info\t''
warn\t''
error\t''"
complete -c espup -n "__fish_espup_using_subcommand update" -s a -l name -d 'Xtensa Rust toolchain name' -r
complete -c espup -n "__fish_espup_using_subcommand update" -s b -l stable-version -d 'Stable Rust toolchain version' -r
complete -c espup -n "__fish_espup_using_subcommand update" -s t -l targets -d 'Comma or space separated list of targets [esp32,esp32c2,esp32c3,esp32c6,esp32h2,esp32s2,esp32s3,esp32p4,all]' -r
complete -c espup -n "__fish_espup_using_subcommand update" -s v -l toolchain-version -d 'Xtensa Rust toolchain version' -r
complete -c espup -n "__fish_espup_using_subcommand update" -s c -l crosstool-toolchain-version -d 'Crosstool-NG toolchain version, e.g. (14.2.0_20241119)' -r
complete -c espup -n "__fish_espup_using_subcommand update" -s r -l esp-riscv-gcc -d 'Install Espressif RISC-V toolchain built with croostool-ng'
complete -c espup -n "__fish_espup_using_subcommand update" -s e -l extended-llvm -d 'Extends the LLVM installation'
complete -c espup -n "__fish_espup_using_subcommand update" -s k -l skip-version-parse -d 'Skips parsing Xtensa Rust version'
complete -c espup -n "__fish_espup_using_subcommand update" -s s -l std -d 'Only install toolchains required for STD applications'
complete -c espup -n "__fish_espup_using_subcommand update" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c espup -n "__fish_espup_using_subcommand help; and not __fish_seen_subcommand_from completions install uninstall update help" -f -a "completions" -d 'Generate completions for the given shell'
complete -c espup -n "__fish_espup_using_subcommand help; and not __fish_seen_subcommand_from completions install uninstall update help" -f -a "install" -d 'Installs Espressif Rust ecosystem'
complete -c espup -n "__fish_espup_using_subcommand help; and not __fish_seen_subcommand_from completions install uninstall update help" -f -a "uninstall" -d 'Uninstalls Espressif Rust ecosystem'
complete -c espup -n "__fish_espup_using_subcommand help; and not __fish_seen_subcommand_from completions install uninstall update help" -f -a "update" -d 'Updates Xtensa Rust toolchain'
complete -c espup -n "__fish_espup_using_subcommand help; and not __fish_seen_subcommand_from completions install uninstall update help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
