# ===========================================================================
# Copyright 2003-2005, Everitz Consulting (mt@everitz.com)
#
# Licensed under the Open Software License version 2.1
# ===========================================================================
package MT::Plugin::PeakEntries;

use base qw(MT::Plugin);
use strict;

use MT;
use MT::Util qw(offset_time_list);

# version
use vars qw($VERSION);
$VERSION = '1.0.0';

my $plugin;
my $about = {
  name => 'MT-PeakEntries',
  description => 'A container tag for the most popular entries.',
  author_name => 'Everitz Consulting',
  author_link => 'http://www.everitz.com/',
  version => $VERSION,
};
$plugin = MT::Plugin::PeakEntries->new($about);
MT->add_plugin($plugin);

use MT::Template::Context;
MT::Template::Context->add_container_tag(PeakEntries => \&PeakEntries);
MT::Template::Context->add_tag(PeakEntriesCommentCount => \&ReturnValue);

sub PeakEntries {
  my($ctx, $args, $cond) = @_;

  # limit entries
  my $limit = $args->{limit} || 0;

  # set time frame
  my $days = $args->{days} || 7;
  return $ctx->error(MT->translate(
    "Invalid data: [_1] must be numeric!", qq(<MTPeakEntries days="$days">))
  ) unless ($days =~ /\d*/);
  my @ago = offset_time_list(time - 60 * 60 * 24 * $days);
  my $ago = sprintf "%04d%02d%02d%02d%02d%02d", $ago[5]+1900, $ago[4]+1, @ago[3,2,1,0];
  my @now = offset_time_list(time);
  my $now = sprintf "%04d%02d%02d%02d%02d%02d", $now[5]+1900, $now[4]+1, @now[3,2,1,0];

  # load entries with comments in last $days
  use MT::Entry;
  use MT::Comment;
  my @entries = MT::Entry->load(
    { status => MT::Entry::RELEASE() },
    { join => [ 'MT::Comment', 'entry_id',
        { created_on => [ $ago, $now ],
          visible => 1 },
        { range => { created_on => 1 },
          unique => 1 } ]}
    );

  # put entries into hash
  my %entries = map { $_->id => MT::Comment->count(
    { entry_id => $_->id,
      created_on => [ $ago, $now ],
      visible => 1 },
    { range => { created_on => 1 }}
  ) } @entries;

  # sort hash by number of comments
  my @entry_ids = sort { $entries{$b} <=> $entries{$a} } keys (%entries);

  # load entries from there into array
  @entries = map { MT::Entry->load($_) } @entry_ids;

  # build container
  my $builder = $ctx->stash('builder');
  my $tokens = $ctx->stash('tokens');
  my $res = '';
  my $done = 0;

  # check for any entries
  foreach (@entries) {
    last if ($limit && $done >= $limit);
    my $count = MT::Comment->count(
      { entry_id => $_->id,
        created_on => [ $ago, $now ],
        visible => 1 },
      { range => { created_on => 1 }}
    );
    eval ("use MT::Promise qw(delay);");
    $ctx->{__stash}{entry} = $_ if $@;
    $ctx->{__stash}{entry} = delay (sub { $_; }) unless $@;
    $ctx->{__stash}{peakentriescommentcount} = $count;
    my $out = $builder->build($ctx, $tokens);
    return $ctx->error($builder->errstr) unless defined $out;
    $res .= $out;
    $done++;
  }
  $res;
}

sub ReturnValue {
  my ($ctx, $args) = @_;
  my $val = $ctx->stash(lc($ctx->stash('tag')));
  $val;
}

1;
