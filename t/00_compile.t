use strict;
use warnings;
use Test::More tests => 5;

BEGIN {
    use_ok 'UUID::Generator::PurePerl';
    use_ok 'UUID::Generator::PurePerl::Compat';
    use_ok 'UUID::Generator::PurePerl::NodeID';
    use_ok 'UUID::Generator::PurePerl::RNG';
    use_ok 'UUID::Generator::PurePerl::Util';
}
