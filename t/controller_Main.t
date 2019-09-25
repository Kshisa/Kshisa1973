use strict;
use warnings;
use Test::More;


use Catalyst::Test 'kshisa';
use kshisa::Controller::Main;

ok( request('/main')->is_success, 'Request should succeed' );
done_testing();
