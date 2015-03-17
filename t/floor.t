use 5.006;
use strict;
use warnings;
use Test::More 0.96;

use Dist::Zilla::Tester;
use Path::Tiny;
use CPAN::Meta;

require Dist::Zilla; # for VERSION

my $root       = 'corpus/DZ';
my $dz_version = int( Dist::Zilla->VERSION );

{
    my $tzil = Dist::Zilla::Tester->from_config( { dist_root => $root }, );
    ok( $tzil, "created test dist" );

    $tzil->build_in;
    my $build_dir = path( $tzil->tempdir->subdir('build') );

    my $meta    = CPAN::Meta->load_file( $build_dir->child("META.json") );
    my $prereqs = $meta->effective_prereqs;

    my $run_req = {
        "strict"         => 0,
        "warnings"       => 0,
        "File::Basename" => 0,
        "File::Spec"     => 3,
    };

    is_deeply( $prereqs->requirements_for(qw/runtime requires/)->as_string_hash,
        $run_req, "runtime requires" );

    my $test_req = {
        "IO::File"   => 1,
        "Test::More" => 0.46,
    };

    is_deeply( $prereqs->requirements_for(qw/test requires/)->as_string_hash,
        $test_req, "test requires" );

    my $test_rec = { "Path::Tiny" => 0.052 };

    is_deeply( $prereqs->requirements_for(qw/test recommends/)->as_string_hash,
        $test_rec, "test recommends" );
}

done_testing;
# COPYRIGHT
