# ===========================================================================
# A Movable Type plugin to show the most popular entries on the system.
# Copyright 2005 Everitz Consulting <everitz.com>.
#
# This program is free software:  You may redistribute it and/or modify it
# it under the terms of the Artistic License version 2 as published by the
# Open Source Initiative.
#
# This program is distributed in the hope that it will be useful but does
# NOT INCLUDE ANY WARRANTY; Without even the implied warranty of FITNESS
# FOR A PARTICULAR PURPOSE.
#
# You should have received a copy of the Artistic License with this program.
# If not, see <http://www.opensource.org/licenses/artistic-license-2.0.php>.
# ===========================================================================
package MT::Plugin::PeakEntries;

use base qw(MT::Plugin);
use strict;

use MT;
use MT::Util qw(offset_time_list);

# version
use vars qw($VERSION);
$VERSION = '1.3.3';

my $about = {
  name => 'MT-PeakEntries',
  description => 'A container tag for the most popular entries.',
  author_name => 'Everitz Consulting',
  author_link => 'http://everitz.com/',
  version => $VERSION,
};
MT->add_plugin(new MT::Plugin($about));

use MT::Template::Context;
MT::Template::Context->add_container_tag(PeakEntries => \&PeakEntries);
MT::Template::Context->add_conditional_tag(PeakEntriesCategoryFooter => \&ReturnValue);
MT::Template::Context->add_conditional_tag(PeakEntriesCategoryHeader => \&ReturnValue);
MT::Template::Context->add_tag(PeakEntriesCommentCount => \&ReturnValue);

sub PeakEntries {
  my($ctx, $args, $cond) = @_;

  # limit entries
  my $lastn = $args->{lastn} || 0;

  # set time frame
  my $days = $args->{days} || 7;
  return $ctx->error(MT->translate(
    "Invalid data: [_1] must be numeric!", qq(<MTPeakEntries days="$days">))
  ) unless ($days =~ /\d*/);
  my @ago = offset_time_list(time - 60 * 60 * 24 * $days);
  my $ago = sprintf "%04d%02d%02d%02d%02d%02d", $ago[5]+1900, $ago[4]+1, @ago[3,2,1,0];
  my @now = offset_time_list(time);
  my $now = sprintf "%04d%02d%02d%02d%02d%02d", $now[5]+1900, $now[4]+1, @now[3,2,1,0];
  my (%args, %terms);

  use MT::Entry;
  $terms{'status'} = MT::Entry::RELEASE();

  # load entries
  my $type = $args->{type} || 'pop';
  if ($type eq 'pop') {
    use MT::Comment;
    $args{'join'} = [
      'MT::Comment', 'entry_id',
      { created_on => [ $ago, $now ],
        visible => 1 },
      { range => { created_on => 1 },
        unique => 1 }
    ];
  } else {
    $terms{'created_on'} = [ $ago, $now ];
    $args{'range'} = { created_on => 1 };
  }
  my @site_entries = MT::Entry->load(\%terms, \%args);
  @site_entries = sort { $b->created_on cmp $a->created_on } @site_entries;

  # filtered entry list (blog)
  my @blog_entries;
  if ($args->{blog}) {
    my %blog = map { $_ => 1 } split(/\sOR\s/, $args->{blog});
    @blog_entries = grep { exists $blog{$_->blog_id} } @site_entries;
  } else {
    @blog_entries = @site_entries;
  }

  # filtered entry list (category)
  my @cat_entries;
  if ($args->{category}) {
    my $category = $args->{category};
    my $negative = ($category =~ s/^NOT\s//) ? 1 : 0;
    use MT::Category;
    my %category =
      map { $_->id => 1 }
      map { MT::Category->load({ label => $_ }) } 
      split(/\sOR\s/, $category);
    foreach (@blog_entries) {
      my $cats;
      my @cat_ids;
      if ($args->{primary}) {
        push @cat_ids, $_->category;
      } else {
        $cats = $_->categories;
        @cat_ids = map { $_->id } @$cats;
      }
      my @cats;
      if ($negative) {
        @cats = grep { !exists $category{$_} } @cat_ids;
        next unless (@cats == @cat_ids);
      } else {
        @cats = grep { exists $category{$_} } @cat_ids;
      }
      push @cat_entries, $_ if (scalar @cats);
    }
  } else {
    @cat_entries = @blog_entries;
  }

  my @entries;
  my %entry_count;
  if ($type eq 'cat') {
    @entries = sort { $a->category->label cmp $b->category->label } @cat_entries;
  } elsif ($type eq 'pop') {
    my %entry = map { $_->id => $_ } @cat_entries;
    %entry_count = map { $_->id => MT::Comment->count(
      { entry_id => $_->id,
        created_on => [ $ago, $now ],
        visible => 1 },
      { range => { created_on => 1 }}
    ) } @cat_entries;
    my @entry_ids = sort { $entry_count{$b} <=> $entry_count{$a} } keys (%entry);
    @entries = map { $entry{$_} } @entry_ids;
  }

  my $builder = $ctx->stash('builder');
  my $tokens = $ctx->stash('tokens');
  my $res = '';

  my $done = 0;
  my $last_cat = 0;
  foreach (@entries) {
    last if ($lastn && $done >= $lastn);
    my $this_cat = $_->category;
    my $next_cat = 0;
    if (defined $entries[$done+1]) {
      $next_cat = $entries[$done+1]->category;
    }
    eval ("use MT::Promise qw(delay);");
    $ctx->{__stash}{entry} = $_ if $@;
    $ctx->{__stash}{entry} = delay (sub { $_; }) unless $@;
    $ctx->{__stash}{PeakEntriesCommentCount} =
      ($type eq 'pop') ? $entry_count{$_->id} : 0;
    $ctx->{__stash}{PeakEntriesCategoryFooter} = ($this_cat ne $next_cat);
    $ctx->{__stash}{PeakEntriesCategoryHeader} = ($this_cat ne $last_cat);
    my $out = $builder->build($ctx, $tokens);
    $last_cat = $this_cat;
    return $ctx->error($builder->errstr) unless defined $out;
    $res .= $out;
    $done++;
  }
  $res;
}

sub ReturnValue {
  my ($ctx, $args) = @_;
  my $val = $ctx->stash($ctx->stash('tag'));
  $val;
}

1;
