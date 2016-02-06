module webapp.comics.service;

import core.time;
import std.conv;
import std.datetime : Clock, DateTime;
import std.file;
import std.path;
import std.string : format;

import inifiled;
import vibe.core.log;
import vibe.data.json;
import vibe.http.client;
import vibe.http.router;
import vibe.http.server;
import vibe.web.i18n;

import webapp.comics.config;

string[] comics = [
    "tas",   // The Argyle Sweater
    "crbc",  // B.C.
    "cl",    // Close to Home
    "dsh",   // Dark Side of the Horse
    "dt",    // Dilbert
    "far",   // Farcus
    "fk",    // Frank & Ernest
    "ga",    // Garfield
    "mcf",   // Moderately Confused
    "nq",    // Non Sequitur
    "ob",    // Overboard
    "pe",    // Peanuts
    "pb",    // Pearls Before Swine
    "crrub", // Rubs
    "crwiz", // Wizard of ID
    "zi",    // Ziggy
];

// A "traits" structure used to define the available translation files at compile time.
struct TranslationContext {
    import std.typetuple;
    // Throw an error when an translation string is missing/mistyped.
    enum enforceExistingKeys = true;
    // The list of supported languages (the same family of languages will
    // automatically be matched to the closest candidate, e.g. en_GB->en_US)
    alias languages = TypeTuple!("en_US");
    // The base name of the translation files - the full names will be
    // example.en_US.po and example.de_DE.po. Any number of these mixin
    // statements can be used.
    mixin translationModule!"labels";
}

@translationContext!TranslationContext
class ComicsService {
    private {
        ComicsConfig config;
    }

    this() {
        auto configFile = buildPath("config", "xkcd.ini");

        if (configFile.exists) {
            readINIFile(config, configFile);
        } else {
            if (!exists("config")) {
                mkdirRecurse("config");
            }
            config.initDefault();
            writeINIFile(config, configFile);
        }

        logTrace("The comics properties are: %s", config);
        logDiagnostic("Initializing the comics service");
    }

    void getXKCD(HTTPServerRequest req, HTTPServerResponse res) {
        immutable PAGE_SHIFT = 3;
        immutable PAGE_SIZE = 2^^PAGE_SHIFT;

        logDebug("Processing xkcd comics");

        auto page = to!int(req.query.get("page", "1")) - 1;
        int beg = page << PAGE_SHIFT;
        int end = beg + PAGE_SIZE;

        int pageCnt = config.xkcd.length >> PAGE_SHIFT;
        if ((config.xkcd.length & (PAGE_SIZE - 1)) > 0) {
            ++pageCnt;
        }

        if (beg >= config.xkcd.length) {
            throw new Exception("Problem rendering the page for xkcd comics");
        }

        Json[] comicList;
        for (int i = beg; i<end && i<config.xkcd.length; ++i) {
            auto elem = config.xkcd[i];
            comicList ~= getXKCDString(elem);
        }

        auto properties = config.xkcd;
        res.headers.addField("Cache-Control", "no-cache, no-store, must-revalidate");
        res.headers.addField("Pragma", "no-cache");
        res.headers.addField("Expires", "0");
        res.render!("xkcd.dt", req, properties, beg, end, page, pageCnt, comicList);
    }

    void getYahoo(HTTPServerRequest req, HTTPServerResponse res) {
        logDebug("Processing yahoo comics");

        DateTime today = cast(DateTime)Clock.currTime();
        string prevLink, nextLink;
        bool changed;

        int year  = to!int(req.query.get("year",  to!string(today.year)));
        int month = to!int(req.query.get("month", to!string(cast(int)today.month))); // Must be cast to get the value I'm looking for
        int day   = to!int(req.query.get("day",   to!string(today.day)));

        if (    year  < today.year  || (year  == today.year
            && (month < today.month || (month == today.month
            &&  day   < today.day)))) {
            changed = true;
            today = DateTime(year,month,day);
            DateTime tomorrow = today + dur!"days"(1);
            nextLink = text("yahoo?year=", tomorrow.year, "&month=", cast(int)tomorrow.month, "&day=", tomorrow.day);
            logDiagnostic("Using the date: %d/%d/%d",year,month,day);
        }

        DateTime yesterday  = today - dur!"days"(1);
        prevLink = text("yahoo?year=", yesterday.year, "&month=", cast(int)yesterday.month, "&day=", yesterday.day);
        logDebug("Got yesterday");

        DateTime sunday = today - dur!"days"(today.dayOfWeek);
        logDebug("Got Sunday");

        DateTime saturday = sunday - dur!"days"(1);
        logDebug("Got Saturday");

        string yesstamp = format("%d%02d%02d", yesterday.year % 100, yesterday.month, yesterday.day);
        logDebug("The time stamp for yesterday is %s",yesstamp);

        string todstamp = format("%d%02d%02d", today.year % 100, today.month, today.day);
        logDebug("The time stamp for today is %s",todstamp);

        string satstamp = format("%d%02d%02d", saturday.year % 100, saturday.month, saturday.day);
        logDebug("The time stamp for Saturday is %s",satstamp);

        string sunstamp = format("%d%02d%02d", sunday.year % 100, sunday.month, sunday.day);
        logDebug("The time stamp for Sunday is %s",sunstamp);

        res.headers.addField("Cache-Control", "no-cache, no-store, must-revalidate");
        res.headers.addField("Pragma", "no-cache");
        res.headers.addField("Expires", "0");
        res.render!("yahoo.dt", comics, today, yesstamp, todstamp, sunstamp, satstamp, prevLink, changed, nextLink);
    }
}

/* Potentially expensive call to get the metadata about an xkcd comic. */
Json getXKCDString(string comic) {
    logDiagnostic("Fetching metadata about XKCD: %s", comic);

    string url = "http://www.xkcd.com/" ~ ("0" == comic ? "info.0.json" : comic ~ "/info.0.json");
    logDiagnostic("The url is: %s", url);

    auto res = requestHTTP(url);
    if (res.statusCode < 300) {
        scope(failure) return Json.undefined;
        auto response = res.readJson();

        logTrace("info.0.json: %s", response);
        return response;
    }

    logWarn("Could not get metadata about XKCD %s", comic);
    return Json.undefined;
}
