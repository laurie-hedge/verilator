#!/usr/bin/env perl
if (!$::Driver) { use FindBin; exec("$FindBin::Bin/bootstrap.pl", @ARGV, $0); die; }
# DESCRIPTION: Verilator: Verilog Test driver/expect definition
#
# Copyright 2003 by Wilson Snyder. This program is free software; you
# can redistribute it and/or modify it under the terms of either the GNU
# Lesser General Public License Version 3 or the Perl Artistic License
# Version 2.0.
# SPDX-License-Identifier: LGPL-3.0-only OR Artistic-2.0

use IO::File;
use POSIX qw(strftime);
use strict;

scenarios(dist => 1);

our $Release_Ok_Re = qr!(^test_regress/t/|^examples/)!;
our $Exempt_Author_Re = qr!(^ci/|^nodist/fastcov.py|^nodist/fuzzer|^test_regress/t/.*\.(v|cpp|h)$)!;
our $Exempt_Files_Re = qr!(^\.|/\.|\.gitignore$|\.dat|\.gprof|\.mem|\.out$|\.png$|\.tree|\.vc$|\.vcd$|^\.)!;
our @Exempt_Files_List = qw(
    Artistic
    CPPLINT.cfg
    LICENSE
    README.rst
    ci/ci-win-compile.ps1
    ci/ci-win-test.ps1
    ci/coverage-upload.sh
    docs/CONTRIBUTING.rst
    docs/CONTRIBUTORS
    docs/_static
    docs/gen
    docs/spelling.txt
    docs/verilated.dox
    include/gtkwave
    include/vltstd
    install-sh
    src/mkinstalldirs
    test_regress/t/t_altera_lpm.v
    test_regress/t/t_flag_f__3.v
    test_regress/t/t_fuzz_eof_bad.v
    test_regress/t/t_incr_void.v
    test_regress/t/t_timing_trace_fst.pl
    test_regress/t/t_wrapper_context.pl
    test_regress/t/t_wrapper_context_fst.pl
    test_regress/t/t_wrapper_context_seq.pl
    test_regress/t/t_wrapper_del_context_bad.pl
    test_regress/t/tsub/t_flag_f_tsub.v
    test_regress/t/tsub/t_flag_f_tsub_inc.v
    verilator.pc.in
    );

my $root = "..";
my $Debug;

my $Exempt_Files_List_Re = '^(' . join('|', (map { quotemeta $_ } @Exempt_Files_List)) . ")";

if (!-r "$root/.git") {
    skip("Not in a git repository");
} else {
    my $files = `cd $root && git ls-files --exclude-standard`;
    my $year = strftime("%Y", localtime);

    $files =~ s/\s+/ /g;
    foreach my $filename (split /\s+/, $files) {
        next if $filename =~ /$Exempt_Files_Re/;
        next if $filename =~ /$Exempt_Files_List_Re/;
        my $fh = IO::File->new("<$root/$filename") or error("$! $filename");
        my $spdx;
        my $copyright;
        my $release;
        while (my $line = $fh->getline) {
            if ($line =~ /SPDX-License-Identifier:/) {
                $spdx = $line;
            } elsif ($line =~ /Copyright 20[0-9][0-9]/) {
                $copyright = $line;
                if ($line !~ /Wilson Snyder|Geza Lore/
                    && !($filename =~ /test_regress/ && $line =~ /Antmicro|Todd Strader/)) {
                    my $yeardash = ($filename =~ m!test_regress/t!) ? $year : $year."-".$year;
                    if ($filename !~ /$Exempt_Author_Re/) {
                        warn "   ".$copyright;
                        error("$filename: Please use standard 'Copyright $yeardash by Wilson Snyder'");
                    }
                }
            } elsif ($line =~ m!Creative Commons Public Domain!
                     || $line =~ m!freely copied and/or distributed!
                     || $line =~ m!placed into the Public Domain!) {
                $release = 1;
            }
        }
        my $release_note;
        if ($release && $filename !~ /$Release_Ok_Re/) {
            $release_note = " (has copyright release, but not part of $Release_Ok_Re)";
        }
        if (!$copyright && (!$release || $release_note)) {
            error("$filename: Please add standard 'Copyright $year ...', similar to in other files" . $release_note);
        }
        if (!$spdx) {
            error("$filename: Please add standard 'SPDX-License_Identifier: ...', similar to in other files");
        }
    }
}

ok(1);
1;
