complete -c espup -n "__fish_use_subcommand" -s h -l help -d 'Print help'
complete -c espup -n "__fish_use_subcommand" -s V -l version -d 'Print version'
complete -c espup -n "__fish_use_subcommand" -f -a "completions" -d 'Generate completions for the given shell'
complete -c espup -n "__fish_use_subcommand" -f -a "install" -d 'Installs Espressif Rust ecosystem'
complete -c espup -n "__fish_use_subcommand" -f -a "uninstall" -d 'Uninstalls Espressif Rust ecosystem'
complete -c espup -n "__fish_use_subcommand" -f -a "update" -d 'Updates Xtensa Rust toolchain'
complete -c espup -n "__fish_use_subcommand" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c espup -n "__fish_seen_subcommand_from completions" -s l -l log-level -d 'Verbosity level of the logs' -r -f -a "{debug	'',info	'',warn	'',error	''}"
complete -c espup -n "__fish_seen_subcommand_from completions" -s h -l help -d 'Print help'
complete -c espup -n "__fish_seen_subcommand_from install" -s d -l default-host -d 'Target triple of the host' -r -f -a "{x86_64-unknown-linux-gnu	'',aarch64-unknown-linux-gnu	'',x86_64-pc-windows-msvc	'',x86_64-pc-windows-gnu	'',x86_64-apple-darwin	'',aarch64-apple-darwin	''}"
complete -c espup -n "__fish_seen_subcommand_from install" -s f -l export-file -d 'Relative or full path for the export file that will be generated. If no path is provided, the file will be generated under home directory (https://docs.rs/dirs/latest/dirs/fn.home_dir.html)' -r -F
complete -c espup -n "__fish_seen_subcommand_from install" -s l -l log-level -d 'Verbosity level of the logs' -r -f -a "{debug	'',info	'',warn	'',error	''}"
complete -c espup -n "__fish_seen_subcommand_from install" -s a -l name -d 'Xtensa Rust toolchain name' -r
complete -c espup -n "__fish_seen_subcommand_from install" -s n -l nightly-version -d 'Nightly Rust toolchain version' -r
complete -c espup -n "__fish_seen_subcommand_from install" -s t -l targets -d 'Comma or space separated list of targets [esp32,esp32c2,esp32c3,esp32c6,esp32h2,esp32s2,esp32s3,esp32p4,all]' -r
complete -c espup -n "__fish_seen_subcommand_from install" -s v -l toolchain-version -d 'Xtensa Rust toolchain version' -r
complete -c espup -n "__fish_seen_subcommand_from install" -s r -l esp-riscv-gcc -d 'Install Espressif RISC-V toolchain built with croostool-ng'
complete -c espup -n "__fish_seen_subcommand_from install" -s e -l extended-llvm -d 'Extends the LLVM installation'
complete -c espup -n "__fish_seen_subcommand_from install" -s k -l skip-version-parse -d 'Skips parsing Xtensa Rust version'
complete -c espup -n "__fish_seen_subcommand_from install" -s s -l std -d 'Only install toolchains required for STD applications'
complete -c espup -n "__fish_seen_subcommand_from install" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c espup -n "__fish_seen_subcommand_from uninstall" -s l -l log-level -d 'Verbosity level of the logs' -r -f -a "{debug	'',info	'',warn	'',error	''}"
complete -c espup -n "__fish_seen_subcommand_from uninstall" -s a -l name -d 'Xtensa Rust toolchain name' -r
complete -c espup -n "__fish_seen_subcommand_from uninstall" -s h -l help -d 'Print help'
complete -c espup -n "__fish_seen_subcommand_from update" -s d -l default-host -d 'Target triple of the host' -r -f -a "{x86_64-unknown-linux-gnu	'',aarch64-unknown-linux-gnu	'',x86_64-pc-windows-msvc	'',x86_64-pc-windows-gnu	'',x86_64-apple-darwin	'',aarch64-apple-darwin	''}"
complete -c espup -n "__fish_seen_subcommand_from update" -s f -l export-file -d 'Relative or full path for the export file that will be generated. If no path is provided, the file will be generated under home directory (https://docs.rs/dirs/latest/dirs/fn.home_dir.html)' -r -F
complete -c espup -n "__fish_seen_subcommand_from update" -s l -l log-level -d 'Verbosity level of the logs' -r -f -a "{debug	'',info	'',warn	'',error	''}"
complete -c espup -n "__fish_seen_subcommand_from update" -s a -l name -d 'Xtensa Rust toolchain name' -r
complete -c espup -n "__fish_seen_subcommand_from update" -s n -l nightly-version -d 'Nightly Rust toolchain version' -r
complete -c espup -n "__fish_seen_subcommand_from update" -s t -l targets -d 'Comma or space separated list of targets [esp32,esp32c2,esp32c3,esp32c6,esp32h2,esp32s2,esp32s3,esp32p4,all]' -r
complete -c espup -n "__fish_seen_subcommand_from update" -s v -l toolchain-version -d 'Xtensa Rust toolchain version' -r
complete -c espup -n "__fish_seen_subcommand_from update" -s r -l esp-riscv-gcc -d 'Install Espressif RISC-V toolchain built with croostool-ng'
complete -c espup -n "__fish_seen_subcommand_from update" -s e -l extended-llvm -d 'Extends the LLVM installation'
complete -c espup -n "__fish_seen_subcommand_from update" -s k -l skip-version-parse -d 'Skips parsing Xtensa Rust version'
complete -c espup -n "__fish_seen_subcommand_from update" -s s -l std -d 'Only install toolchains required for STD applications'
complete -c espup -n "__fish_seen_subcommand_from update" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c espup -n "__fish_seen_subcommand_from help; and not __fish_seen_subcommand_from completions; and not __fish_seen_subcommand_from install; and not __fish_seen_subcommand_from uninstall; and not __fish_seen_subcommand_from update; and not __fish_seen_subcommand_from help" -f -a "completions" -d 'Generate completions for the given shell'
complete -c espup -n "__fish_seen_subcommand_from help; and not __fish_seen_subcommand_from completions; and not __fish_seen_subcommand_from install; and not __fish_seen_subcommand_from uninstall; and not __fish_seen_subcommand_from update; and not __fish_seen_subcommand_from help" -f -a "install" -d 'Installs Espressif Rust ecosystem'
complete -c espup -n "__fish_seen_subcommand_from help; and not __fish_seen_subcommand_from completions; and not __fish_seen_subcommand_from install; and not __fish_seen_subcommand_from uninstall; and not __fish_seen_subcommand_from update; and not __fish_seen_subcommand_from help" -f -a "uninstall" -d 'Uninstalls Espressif Rust ecosystem'
complete -c espup -n "__fish_seen_subcommand_from help; and not __fish_seen_subcommand_from completions; and not __fish_seen_subcommand_from install; and not __fish_seen_subcommand_from uninstall; and not __fish_seen_subcommand_from update; and not __fish_seen_subcommand_from help" -f -a "update" -d 'Updates Xtensa Rust toolchain'
complete -c espup -n "__fish_seen_subcommand_from help; and not __fish_seen_subcommand_from completions; and not __fish_seen_subcommand_from install; and not __fish_seen_subcommand_from uninstall; and not __fish_seen_subcommand_from update; and not __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
