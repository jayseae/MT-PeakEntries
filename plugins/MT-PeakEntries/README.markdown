# MT-AltEntries plugin for Movable Type #

This [Movable Type](http://www.movabletype.org) plugin provides an entry container that shows you the most popular entries across all blogs on your system (by number of comments).

## Version ##

1.0.0

## Requirements ##

* Movable Type

## License ##

This program is distributed under the terms of the GNU General Public License, version 2.

## Installation ##

Install the necessary files to your web server.  MT_HOME is the location of your primary Movable Type installation (mt.cgi can be found here).

Simply drop the directory `plugins/MT-PeakEntries` contained in this archive into your `MT_HOME/plugins` directory.

If you are running under FastCGI or other persistent environment, you will need to restart your webserver in order to activate the plugin in your Movable Type installation.

## Template Tags ##

Once installed, a new container tag is enabled in your Movable Type installation:

<MTPeakEntries>
    
You would use this container in place of the standard <MTEntries> container that ships with Movable Type.

The difference is that MTPeakEntries counts all the comments left on each of your entries (across all blogs) and sorts the list (in descending order) based on that count.

All standard entry context tags should work within this container.

This plugin also provides another tag that will display the number of comments during the examined period:

<MTPeakEntriesCommentCount>
    
If you want to show the number of comments in this period, as opposed to the total number of comments on the entry, you'll need to use this tag.

## Usage ##

The container tag permits two optional attributes to customize the output generated from the plugin.

Add "days" to restrict the number of days used for the counting of comments on the entries found, for instance "most popular over the last 60 days".

Here is an example of using this attribute:

<MTPeakEntries days="60">
<a href="<$MTEntryPermalink$>"><$MTEntryTitle$></a><br />
</MTPeakEntries>

This example will examine all comments over the last 60 days, and produce a listing of the entries over that time with the most comments.

For performance reasons, if this attribute is not specified, the default is 7 days.

Add "limit" to restrict the number of entries displayed, useful if you want to display a "most popular entries" display.  If there are fewer results than the value of limit, the display will stop there.

Here is an example of using this attribute:

<MTPeakEntries limit="5">
<a href="<MTEntryPermalink>"><MTEntryTitle></a><br />
</MTPeakEntries>

This will examine all entries and return the top 5 (by number of comments), sorted in descending order.

There is no default limit, meaning if you don't include one, it will show all entries over the time period - potentially a long list!

The attributes can be combined, to produce (for example), the top 25 entries over the last 30 days.

## Version History ##

* 2005/08/24 - Initial Public Release

## Support ##

Nobody supports this software.  Use it at your own risk.

## Author ##

This plugin was brought to you by [Everitz Consulting](http://everitz.com/).

## Copyright ##

Copyright 2005, [Everitz Consulting](http://everitz.com/).
