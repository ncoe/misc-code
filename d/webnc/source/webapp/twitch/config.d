module webapp.twitch.config;

import std.array : appender;

import inifiled;

import vibe.core.log;

@INI("Twitch App Configuration")
struct TwitchConfig {
    @INI("Streamers that should be checked")
    string[] following;
}

void initDefault(ref TwitchConfig config) {
    auto builder = appender!(string[])();

    builder.put("soaryn");
    builder.put("fireball1725dev");
    builder.put("mdiyo");
    builder.put("morvelaira");
    builder.put("xcompwiz");

    builder.put("arashidragon");
    builder.put("aureylian");
    builder.put("bacon_donut");
    builder.put("direwolf20");
    builder.put("eddieruckus");
    builder.put("jadedcat");
    builder.put("jonbams");
    builder.put("kihira");
    builder.put("ksptv");
    builder.put("lexmanos");
    builder.put("minalien");
    builder.put("minecraftcpw");
    builder.put("myrathi");
    builder.put("mysteriousages");
    builder.put("ohaiichun");
    builder.put("pahimar");
    builder.put("progwml6");
    builder.put("quetzi");
    builder.put("sacheverell");
    builder.put("slowpoke101");
    builder.put("straymav");
    builder.put("syndicate");
    builder.put("tahg");
    builder.put("themattabase");
    builder.put("tfox83");
    builder.put("tlovetech");
    builder.put("vswe");
    builder.put("wolv21");
    builder.put("wyld");
    builder.put("x3n0ph0b3");

    config.following = builder.data.idup;
    logDebug("following: %s", config.following);
}
