use Modern::Perl '2015';
use File::Basename;

my $filedata = 'quality.txt';

my $dir = 'sony\\Q';
my $file_src = 'sony\\DSC_0012.JPG';

die "No such file: $file_src\n" unless (-e $file_src);

quality_for();

sub quality_for {#{{{
	my ($fn, $directories, $ext) =
		fileparse($file_src, '\.[^\.]*');

	my $Q = 'convert';

	mkdir($dir) unless (-e $dir);
	for my $quality (11 .. 99) {
		my $f2 = "$dir\\q.$quality.$fn.$ext";
		my $cmd = "$Q -quality $quality \"$file_src\" \"$f2\"";
		# say `$cmd`;
	}

	quality_for_stat();
}#}}}
sub quality_for_stat {#{{{
	use File::Find;

	my $re_q = qr/(\d+)[^\d]+(\d+)/;

	my %stat;

	my $scan = sub {
		# say $File::Find::name;
		# say $_;
		my $f1 = $_;
	my ($fn, $directories, $ext) =
		fileparse($f1, '\.[^\.]*');

		return unless ($fn);
		return unless ($f1 =~ /$re_q/);

		my $quality  = $1;
		my $filename = $2;
		my $filesize = (stat $f1)[7];

		my $log = sprintf "%2d %8d\n", $quality, $filesize;
		# print "$filename \t $log";

		$stat{$filename}{$quality} = $filesize;
	};
	find($scan, $dir);

	quality_log(%stat);
}#}}}
sub quality_log {#{{{
	my %stat = @_;

	my @filename_static = sort keys %stat;

	my %filename_biggest;
	for my $filename (keys %stat) {
		my $filesize_biggest =
		(sort {
			$b <=> $a
		} (values %{$stat{$filename}})
		)[0];

		say "filename_biggest> $filename $filesize_biggest";

		$filename_biggest{$filename} = $filesize_biggest;
	}

	my %keys_quality;
	for my $filename (keys %stat) {
		for my $quality (keys %{$stat{$filename}}) {
			$keys_quality{$quality} = 1;
		}
	}

	my @accum;

	for my $quality (sort keys %keys_quality) {
		# print "\n$quality";

		my $log = '';

		for my $filename (@filename_static) {
			my $filesize = $stat{$filename}{$quality};

			# $log .= sprintf "%8d", $filesize;

			# printf "for> $filename $quality %8d\n", $filesize;

			my $filesize_biggest = $filename_biggest{$filename};

			unless (defined $filesize_biggest) {
				say "quality_log error: $filename $quality";
				next;
			}

			$filesize = 100.0 * $filesize / $filesize_biggest;
			$log .= sprintf "%3d ", $filesize;
		}

		$log = "$quality $log";

		push @accum, $log;
	}

	open my $fh_data, "+> $filedata" or die "Can't create '$filedata': $!\n";
	
	for my $log (@accum) {
		say $fh_data "$log";
		say $log;
	}

	close $fh_data;
}#}}}
