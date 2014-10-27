import json
import logging
import urllib2
import webbrowser
from time import sleep

DEBUG = False

baseStreamUri = 'https://api.twitch.tv/kraken/streams/'

following = [
    'fireball1725dev',
    'mdiyo',
    'morvelaira',
    'soaryn',
    'xcompwiz',

    'arashidragon',
    'aureylian',
    'bacon_donut',
    'cpw11',
    'direwolf20',
    'eddieruckus',
    'jadedcat',
    'kihira',
    'ksptv',
    'lexmanos',
    'minalien',
    'minecraftcpw',
    'myrathi',
    'mysteriousages',
    'ohaiichun',
    'pahimar',
    'progwml6',
    'quetzi',
    'sacheverell',
    'slowpoke101',
    'straymav',
    'syndicate',
    'tahg',
    'themattabase',
    'tfox83',
    'tlovetech',
    'vswe',
    'wolv21',
    'wyld',
    'x3n0ph0b3',
]

####################################################################################################

def promptYN(msg):
    while (True):
        choice = raw_input(msg + ' (Y/N):')
        if (choice == 'y' or choice == 'Y'):
            return True
        elif (choice == 'n' or choice == 'N'):
            return False
        else:
            print 'ERROR - Unrecognized option: ' + choice

def sendRequest(link):
    try:
        if DEBUG:
            print link

        request = urllib2.Request(link)
        response = urllib2.urlopen(request,None,10)
        jsonstr = response.read()

        if DEBUG:
            print "Response:\n", jsonstr, "\n";

        jsonres = json.loads(jsonstr)
        return jsonres
    except:
        if DEBUG:
            print "Response:\nERROR\n"
        return json.loads('{}')

####################################################################################################

following.sort()
livearr = []

for streamer in following:
    link = baseStreamUri + streamer

    jsonres = sendRequest(link)

    stream = jsonres.get('stream')
    if stream is not None:
        channel = stream.get('channel')
        game = stream.get('game') # This may be null and still valid
        title = channel.get('status') # Why is this status?

        if game is None:
            game = '<UNKNOWN GAME>'

        if title is None:
            title = '<UNTITLED>'

        entry = {}
        entry['player'] = streamer
        entry['game'] = game
        entry['title'] = title
        livearr.append(entry)

        print
        print streamer
        print '\t', game
        print '\t', title.encode('ascii','ignore')
        print
    else:
        print streamer
print

####################################################################################################

singlebase = 'http://www.twitch.tv/'
multibase = 'http://www.multitwitch.tv/'
if (0 == len(livearr)):
    print 'nobody is live'
    sleep(5)
else:
    watch = []
    for live in livearr:
        if (promptYN('Would you like to watch ' + live['player'] + ' play ' + live['game'] + '?')):
            watch.append(live)

    if (1 == len(watch)):
        # link = singlebase + watch[0]['player']
        link = multibase + watch[0]['player']
        if DEBUG:
            print link
        else:
            webbrowser.open_new_tab(link)
    elif (0 < len(watch)):
        link = multibase + '/'.join(map(lambda x: x['player'], watch))
        if DEBUG:
            print link
        else:
            webbrowser.open_new_tab(link)
