use strict;
use warnings;
use Test::More;


use Catalyst::Test 'kshisa';
use kshisa::Controller::Friends;

ok( request('/friends')->is_success, 'Request should succeed' );
done_testing();
