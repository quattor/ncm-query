# -*- mode: cperl -*-
use strict;
use warnings;
use Test::More;
use Test::Quattor qw(load);
use Test::MockModule;
use EDG::WP4::CCM::Element;

use Readonly;

Readonly my $SCRIPT => 'src/main/scripts/ncm-query';

Readonly my $EXPECTED => <<'EOF';
+-/
 +-level1
  +-/more/unescape/
   $ yeah : (string) '/more/unescape'
  $ _2funescape_2f : (string) 'unescape'
  $ hello : (string) 'level1'
  +-level2
   $ boolean : (boolean) 'true'
   $ double : (string) '0.5'
   +-level3
    $ hello : (string) 'level3'
   +-list
    $ 0 : (string) '1'
    $ 1 : (string) '2'
    $ 2 : (string) '3'
   $ long : (string) '10'
   +-nlist
    $ nlist : (string) 'ok'
   $ string : (string) 'string'
EOF

Readonly my $EXPECTED_LEVEL_TWO => <<'EOF';
+-/
 +-level1
  +-/more/unescape/
  $ _2funescape_2f : (string) 'unescape'
  $ hello : (string) 'level1'
  +-level2
EOF

# TODO This is wrong due to JSON and typeless perl.
Readonly my $EXPECTED_PAN => <<'EOF';
"/level1/_2fmore_2funescape_2f/yeah" = "/more/unescape"; # string
"/level1/_2funescape_2f" = "unescape"; # string
"/level1/hello" = "level1"; # string
"/level1/level2/boolean" = true; # boolean
"/level1/level2/double" = "0.5"; # string
"/level1/level2/level3/hello" = "level3"; # string
"/level1/level2/list/0" = "1"; # string
"/level1/level2/list/1" = "2"; # string
"/level1/level2/list/2" = "3"; # string
"/level1/level2/long" = "10"; # string
"/level1/level2/nlist/nlist" = "ok"; # string
"/level1/level2/string" = "string"; # string
EOF

Readonly my $EXPECTED_PATHS => <<'EOF';
/level1/_2fmore_2funescape_2f/yeah
/level1/_2funescape_2f
/level1/hello
/level1/level2/boolean
/level1/level2/double
/level1/level2/level3/hello
/level1/level2/list/0
/level1/level2/list/1
/level1/level2/list/2
/level1/level2/long
/level1/level2/nlist/nlist
/level1/level2/string
EOF

Readonly my $EXPECTED_PATHS_DEPTH_1_REL_LEVEL1 => <<'EOF';
/level1/_2fmore_2funescape_2f/
/level1/_2funescape_2f
/level1/hello
/level1/level2/
EOF

my $text='';

my $mock = Test::MockModule->new("CAF::Reporter");
$mock->mock("report",  sub {
    my ($self, @args) = @_;
    $text .= join('', @args) . "\n";
});


=pod

=HEAD1 DESCRIPTION

Test the basic ncm-query functionality

=cut

open FH, $SCRIPT;
my $script = join('', <FH>);
close FH;

# just don't run it
eval "sub {$script};";

# Can we test this? or will the whole test fail?
# is($?, 0, "eval ncm-query ok"); 

=pod

=HEAD2 options

Test option generation

=cut

my $opts = query::app_options();
my $options = [];
foreach my $opt (@$opts) {
    push(@$options, $opt->{NAME});
}

is(scalar @$opts, 13, scalar @$opts." options generated");
is_deeply($options, ['dump=s', , 'isactive=s', 'components=s', 'cache_root:s', 
                     'useprofile:s', 'pan', 'deref', 'deriv', 'unescape!', 
                     'indentation', 'depth=s', 'paths', 'format:s',
                     ], "expected options");

=pod

=HEAD2 main

Test main functions

=cut

my $cfg = get_config_for_profile('load');
my $root = $cfg->getElement("/");
my $settings = {
    MAP => {
        EDG::WP4::CCM::Element::STRING => 'string',
        EDG::WP4::CCM::Element::LONG => 'long',
        EDG::WP4::CCM::Element::DOUBLE => 'double',
        EDG::WP4::CCM::Element::BOOLEAN => 'boolean',
        },
    DEREFERENCE => 0,
    DERIVATION => 0,
    UNESCAPE => 1,
    INDENTATION => ' ',
    REPORT_STYLE_TREE => 1,
};

main::search($root, 0, $settings);
is($text, $EXPECTED, "Search generated correct results");

=pod

=HEAD2 test indentation

Test the indentation setting

=cut

my $exp_noindent = "$EXPECTED";
$exp_noindent =~ s/^ +//mg;
$settings->{INDENTATION} = '';

# reset text and root
$text='';
$root = $cfg->getElement("/");
main::search($root, 0, $settings);
is($text, $exp_noindent, "Search generated correct non-indented results");
$settings->{INDENTATION} = ' ';

=pod

=HEAD2 test pan

Test the pan reporting

=cut

$settings->{REPORT_STYLE_TREE} = 0;
$settings->{REPORT_STYLE_PAN} = 1;
# reset text and root
$text='';
$root = $cfg->getElement("/");
main::search($root, 0, $settings);
is($text, $EXPECTED_PAN, "Search generated correct pan style results");
$settings->{REPORT_STYLE_TREE} = 1;
$settings->{REPORT_STYLE_PAN} = 0;

=pod

=HEAD2 test pan

Test the pan reporting

=cut

$settings->{REPORT_STYLE_TREE} = 0;
$settings->{REPORT_STYLE_PATHS} = 1;
# reset text and root
$text='';
$root = $cfg->getElement("/");
main::search($root, 0, $settings);
is($text, $EXPECTED_PATHS, "Search generated correct paths style results");
$settings->{REPORT_STYLE_TREE} = 1;
$settings->{REPORT_STYLE_PATHS} = 0;

=pod

=HEAD2 test max depth

Test the depth setting limiting the number of levels shown.

=cut

# up to level 2 (/ is level0)
$settings->{MAX_DEPTH} = 2;

# reset text and root
$text='';
$root = $cfg->getElement("/");
main::search($root, 0, $settings);
is($text, $EXPECTED_LEVEL_TWO, "Search generated correct level 2 results");
$settings->{MAX_DEPTH} = undef;

=pod

=HEAD2 test max depth combination with paths and relative path

A combined test of paths, depth and non-root path (e.g. for tab completion)

=cut

$settings->{MAX_DEPTH} = 1;
$settings->{REPORT_STYLE_TREE} = 0;
$settings->{REPORT_STYLE_PATHS} = 1;

# reset text and root
$text='';
$root = $cfg->getElement("/level1");
main::search($root, 0, $settings);
is($text, $EXPECTED_PATHS_DEPTH_1_REL_LEVEL1, "Search generated correct /level1  paths depth=1 results");

$settings->{MAX_DEPTH} = undef;
$settings->{REPORT_STYLE_TREE} = 1;
$settings->{REPORT_STYLE_PATHS} = 0;


done_testing();