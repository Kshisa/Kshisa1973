use strict;
use warnings;

use kshisa;

my $app = kshisa->apply_default_middlewares(kshisa->psgi_app);
$app;

