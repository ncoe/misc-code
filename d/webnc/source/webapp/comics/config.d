module webapp.comics.config;

import std.array : appender;

import inifiled;

import vibe.core.log;

@INI("Comics App Configuration")
struct ComicsConfig {
    @INI("Favorite XKCD comics")
    string[] xkcd;
}

void initDefault(ref ComicsConfig config) {
    auto builder = appender!(string[])();

    // Most Recent XKCD
    builder.put("0");

    // Donner
    builder.put("30");

    // Velociraptors
    builder.put("87");

    // Substitute
    builder.put("135");

    // Pointers
    builder.put("138");

    // Donald Knuth
    builder.put("163");

    // Regular Expressions
    builder.put("208");

    // Random Number
    builder.put("221");

    // Lisp
    builder.put("224");

    // Color Codes
    builder.put("227");

    // Battle Room
    builder.put("241");

    // The Difference
    builder.put("242");

    // Labyrinth Puzzle
    builder.put("246");

    // Goto
    builder.put("292");

    // RTFM
    builder.put("293");

    // Compiling
    builder.put("303");

    // Excessive Quotation
    builder.put("307");

    // Engineering Hubris
    builder.put("319");

    // A-Minus-Minus
    builder.put("325");

    // Exploits of a Mom
    builder.put("327");

    // Compiler Complaint
    builder.put("371");

    // Pod Bay Doors
    builder.put("375");

    // Real Programmers
    builder.put("378");

    // Duty Calls
    builder.put("386");

    // Electric Skateboard
    builder.put("409");

    // Zealous Autoconfig
    builder.put("416");

    // Purity
    builder.put("435");

    // Height
    builder.put("482");

    // Depth
    builder.put("485");

    // Flow Charts
    builder.put("518");

    // I'm an Idiot
    builder.put("530");

    // Genetic Algorithms
    builder.put("534");

    // Parking
    builder.put("562");

    // Security Question
    builder.put("565");

    // Packages
    builder.put("576");

    // Brakes
    builder.put("582");

    // Form
    builder.put("608");

    // Tab Explosion
    builder.put("609");

    // Estimation
    builder.put("612");

    // Tech Support Cheat Sheet
    builder.put("627");

    // Prudence
    builder.put("665");

    // Experiment
    builder.put("669");

    // Self-Description
    builder.put("688");

    // Devotion to Duty
    builder.put("705");

    // Dependencies
    builder.put("754");

    // Tech Support
    builder.put("806");

    // Applied Math
    builder.put("816");

    // Tic-Tac-Toe
    builder.put("832");

    // Incident
    builder.put("838");

    // Good Code
    builder.put("844");

    // Nanobots
    builder.put("865");

    // Server Attention Span
    builder.put("869");

    // Rogers St
    builder.put("884");

    // Religions
    builder.put("900");

    // Darmok and Jalad
    builder.put("902");

    // The Cloud
    builder.put("908");

    // Password Strength
    builder.put("936");

    // TornadoGuard
    builder.put("937");

    // Chin-Up Bar
    builder.put("954");

    // The Important Field
    builder.put("970");

    // Wisdom of the Ancients
    builder.put("979");

    // Game AIs
    builder.put("1002");

    // Error Code
    builder.put("1024");

    // Server Problem
    builder.put("1084");

    // Cirith Ungol
    builder.put("1087");

    // Formal Languages
    builder.put("1090");

    // Frequentists vs. Bayesians
    builder.put("1132");

    // Logic Boat
    builder.put("1134");

    // Proof
    builder.put("1153");

    // Debugger
    builder.put("1163");

    // tar
    builder.put("1168");

    // Bridge
    builder.put("1170");

    // Perl Problems
    builder.put("1171");

    // Workflow
    builder.put("1172");

    // App
    builder.put("1174");

    // Time Robot
    builder.put("1177");

    // ISO "8601"
    builder.put("1179");

    // Virus Venn Diagram
    builder.put("1180");

    // PGP
    builder.put("1181");

    // Circumference Formula
    builder.put("1184");

    // Ineffective Sorts
    builder.put("1185");

    // Aspect Ratio
    builder.put("1187");

    // Bonding
    builder.put("1188");

    // Voyager "1"
    builder.put("1189");

    // Flowchart
    builder.put("1195");

    // All Adobe Updates
    builder.put("1197");

    // Authorization
    builder.put("1200");

    // Integration By Parts
    builder.put("1201");

    // Time Machines
    builder.put("1203");

    // Is It Worth The Time?
    builder.put("1205");

    // Encoding
    builder.put("1209");

    // I'm So Random
    builder.put("1210");

    // Interstellar memes
    builder.put("1212");

    // Insight
    builder.put("1215");

    // Nomenclature
    builder.put("1221");

    // Douglas Engelbart (1925-2013)
    builder.put("1234");

    // The Mother of All Suspicious Files
    builder.put("1247");

    // Unquote
    builder.put("1262");

    // Halting Problem
    builder.put("1266");

    // Functional
    builder.put("1270");

    // Monty Hall
    builder.put("1282");

    // Puzzle
    builder.put("1287");

    // Sigil Cycle
    builder.put("1306");

    // Haskell
    builder.put("1312");

    // Regex Golf
    builder.put("1313");

    // Inexplicable
    builder.put("1316");

    // Automation
    builder.put("1319");

    // Protocol
    builder.put("1323");

    // Update
    builder.put("1328");

    // When You Assume
    builder.put("1339");

    // Types of Editors
    builder.put("1341");

    // Manuals
    builder.put("1343");

    // Shouldn't Be Hard
    builder.put("1349");

    // Old Files
    builder.put("1360");

    // Google Announcement
    builder.put("1361");

    // Margin
    builder.put("1381");

    // Power Cord
    builder.put("1395");

    // Query
    builder.put("1409");

    // Seven
    builder.put("1417");

    // Future Self
    builder.put("1421");

    // Tasks
    builder.put("1425");

    // Move Fast and Break Things
    builder.put("1428");

    // Data
    builder.put("1429");

    // The Sake of Argument
    builder.put("1432");

    // Higgs Boson
    builder.put("1437");

    // Houston
    builder.put("1438");

    // Rack Unit
    builder.put("1439");

    // Geese
    builder.put("1440");

    config.xkcd = builder.data.idup;
    logDebug("xkcd comics: %s", config.xkcd);
}
