# -*- mode: cperl -*-
use strict;
use warnings;
use Test::More;
use Test::Quattor qw(load);
use Test::MockModule;

use Readonly;

Readonly my $SCRIPT => 'src/main/scripts/ncm-query';

Readonly my $EXPECTED => <<'EOF';
+-/
 +-level0
  +-/more/unescape/
   $ yeah : (string) '/more/unescape'
  $ _2funescape_2f : (string) 'unescape'
  $ hello : (string) 'level0'
  +-level1
   $ boolean : (boolean) 'true'
   $ double : (string) '0.5'
   +-level2
    $ hello : (string) 'level2'
   +-list
    $ 0 : (string) '1'
    $ 1 : (string) '2'
    $ 2 : (string) '3'
   $ long : (string) '10'
   +-nlist
    $ nlist : (string) 'ok'
   $ string : (string) 'string'
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

is(scalar @$opts, 10, scalar @$opts." options generated");
is_deeply($options, ['dump=s', , 'isactive=s', 'components=s', 'cache_root:s', 
                     'useprofile:s', 'pan', 'deref', 'deriv', 'unescape!', 
                     'indentation',
                     ], "expected options");

=pod

=HEAD2 main

Test main functions

=cut

my $cfg = get_config_for_profile('load');
my $root = $cfg->getElement("/");
my $settings = {
    REPORT_PAN_STYLE => 0,
    DEREFERENCE => 0,
    DERIVATION => 0,
    UNESCAPE => 1,
    INDENTATION => ' ',
};

main::search($root, 0, $settings);
is($text, $EXPECTED, "Search generated correct results");

done_testing();
