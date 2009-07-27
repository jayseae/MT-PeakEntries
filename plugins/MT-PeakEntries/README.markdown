# MT-AltEntries plugin for Movable Type #

This [Movable Type](http://www.movabletype.org) plugin provides an entry container that permits the display of either the most popular entries on your system (by number of comments) or the use of the "days" attribute along with the category selection.

## Version ##

1.1.0

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

Within the category listing, you can also use the template tags:

    <MTPeakEntriesCategoryHeader>
    <MTPeakEntriesCategoryFooter>

These container tags are useful for creating more complex loops of data, and work much like the similar constructs in Movable Type.

## Usage ##

The container tag permits optional attributes to customize the output generated from the plugin.

The default attribute, "pop", will return the most popular entries (by number of comments).  This example might look something like this:

    <MTPeakEntries type="pop">
    <a href="<$MTEntryPermalink$>"><$MTEntryTitle$></a><br />
    </MTPeakEntries>

This example will show the most popular entries (all of them!) for the last 7 days - the default if no days attribute is specified.

If you would like to instead see the most recent entries across several of your categories - or even just one of them - you can instead specify the "cat" attribute, so that your example may look like this:

    <MTPeakEntries type="cat">
    <a href="<$MTEntryPermalink$>"><$MTEntryTitle$></a><br />
    </MTPeakEntries>

This will now list entries by category, which can be restricted by the values you specify in the next section.

## Cutomization ##

Add "blog" to restrict the output to content from only a particular blog or set of blogs.  Use the blog ID (or IDs) in the attribute, not the blog name.

Here is an example of using this attribute:

    <MTPeakEntries type="pop" blog="1 OR 2">
    <a href="<$MTEntryPermalink$>"><$MTEntryTitle$></a><br />
    </MTPeakEntries>

This example will include the most popular content from blogs 1 or 2.

Add "category" to restrict the output to content from only a particular category or set of categories.  Use the category name (or names) in the attribute, not the category ID.

Here is an example of using this attribute:

    <MTPeakEntries type="pop" category="Foo OR Bar">
    <a href="<$MTEntryPermalink$>"><$MTEntryTitle$></a><br />
    </MTPeakEntries>

This example will include the most popular content from category Foo or Bar.

** If you combine the blog and category attributes, your results may be somewhat unexpected.  First, the category selector will be used, then the blog filter will be applied.  If you then apply a lastn selection, that will be the last filter to your data.  **

For performance reasons, if the days attribute is not specified, the default is 7 days!

Add "days" to restrict the number of days used for the counting of comments on the entries found, for instance "most popular over the last 60 days".

Here is an example of using this attribute:

    <MTPeakEntries type="pop" days="60">
    <a href="<$MTEntryPermalink$>"><$MTEntryTitle$></a><br />
    </MTPeakEntries>

This example will examine all comments over the last 60 days, and produce a listing of the entries over that time with the most comments.

** For performance reasons, if the days attribute is not specified, the default is 7 days! **

Add "limit" to restrict the number of entries displayed, probably most useful if you want to display a "most popular entries" display.  If there are fewer results than the value of limit, the display will stop there.

Here is an example of using this attribute:

    <MTPeakEntries limit="5">
    <a href="<MTEntryPermalink>"><MTEntryTitle></a><br />
    </MTPeakEntries>

This will examine all entries and return the top 5, sorted in descending order.

There is no default limit, meaning if you don't include one, it will show all entries over the time period - potentially a long list!

The attributes can be combined, to produce (for example), the top 25 entries over the last 30 days.

## Version History ##

* 2005/09/14 - 1.2.0 - Added Negative Category Processing
* 2005/09/11 - 1.1.0 - Added "cat" Mode and Related Processing
* 2005/08/24 - 1.0.0 - Initial Public Release

## Support ##

Nobody supports this software.  Use it at your own risk.

## Author ##

This plugin was brought to you by [Everitz Consulting](http://everitz.com/).

## Copyright ##

Copyright 2005, [Everitz Consulting](http://everitz.com/).
