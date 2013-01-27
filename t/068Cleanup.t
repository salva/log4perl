use strict;

BEGIN { 
    if($ENV{INTERNAL_DEBUG}) {
        require Log::Log4perl::InternalDebug;
        Log::Log4perl::InternalDebug->enable();
    }
}

use Test::More;
use Carp qw( cluck );
plan tests => 1;
use Log::Log4perl qw( :easy );

my $conf = qq(
  log4perl.category       = DEBUG, Test
  log4perl.appender.Test  = Log::Log4perl::Appender::TestCleanup
  log4perl.appender.Test.composite = 1
  log4perl.appender.Test.layout = Log::Log4perl::Layout::SimpleLayout
);

Log::Log4perl->init(\$conf);

our $too_late = 0;

my $app = Log::Log4perl->appender_by_name("Test");
$app->reg_cb( sub {
      # cluck "we're being cleaned up!";
    ok( $too_late == 0, "cleaned up on time" );
} );

Log::Log4perl::Logger->cleanup();

  # $app should be the last reference, the cleanup should happen
  # right after the 'undef' command in the next line. If it happens
  # afterwards, it's too late.
undef $app;
$too_late = 1;