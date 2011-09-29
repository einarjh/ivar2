local trim = function(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

local meh = {
	['^god natt'] = 'svekling!',
}

local caseinsensitive = {
        ['^eerin eerin'] = 'tasukete ERINNNNNN!!',
}

local wordlist = {
        ['^Yokohama.?$'] = {'RIGHT OVER THERE! o/','OVER HERE! .|o.|','.\o OVER HERE!','DER BORTE! o-','ZOMG!'},
	['^tadaima$'] = {'okaeri','okaaeriii','おかえり！'},
	['^tadaima!$'] = {'okaeri!','okaeriii!','おかえりーーー！'},
	['^ただいま$'] = 'おかえり',
	['^gossun gossun$'] = 'gossun kugi!',
        ['^GOSSUN GOSSUN$'] = 'gossun kugi!',
        ['^DAME DAME DAME DAME NINGEN$'] = 'NINGEEEEN NINGEEEEN',
        ['^mud$'] = 'kip',
        ['*kose viddy*'] = 'fu',
	['*KOSE VIDDY*'] = 'fu..',
        ['^pizza$'] = 'hva skjer med rømmedressingen a?!',
        ['^hva skjer med r.*mmedressingen a'] = 'dunno',
	['^God morgen$'] = {'morn!','mornings!','gudd mørning!','mårn!','mårndu!'},
        ['^god morgen$'] = {'morn!','mornings!','gudd mørning!','mårn!','mårndu!'},
        ['^God dag$'] = {'huheei!','hellauen!','god dagens!','tjohei!','næmmen hei!','hællæ!','tjohei kjøttdeig!'},
        ['^god dag$'] = {'huheei!','hellauen!','god dagens!','tjohei!','næmmen hei!','hællæ!','tjohei kjøttdeig!'},
	['sos sos sos'] = {'OOOH! GODMAN!','Oooh! Godman!','Oooooh! Godmaan!','Ooh! Godman!','OOOOOH GODMAN!','OOooOo GODMAN!'},
	['^cheetamen$'] = {'ole ole!','OLE OLE!'},
        ['^CHEETAMEN$'] = {'ole ole!','OLE OLE!'},
        ['^cheetahmen$'] = {'ole ole!','OLE OLE!'},
        ['^CHEETAHMEN$'] = {'ole ole!','OLE OLE!'},
	['pero pero'] = {'dooon\'t touch me.','don\'t touch me.','don\'t. touch. me.','don\'t touch mee.'},
        ['(　ﾟ∀ﾟ)o彡'] = 'GTFO!',
        ['^tadaima$'] = {'okaeri','okaaeriii','おかえり！'},
        ['^tadaima!$'] = {'okaeri!','okaeriii!','おかえりーーー！'},
        ['^ただいま$'] = 'おかえり',
} 

local caseTable
local case = function(str)
	local out
	local i = 0
	local n = #caseTable + 1
	for char in str:gmatch"([%z\1-\127\194-\244][\128-\191]*)" do
		out = (out or '') .. caseTable[i % n](char)

		i = i + 1
	end
	return out
end

local buildCaseTable = function(msg)
        caseTable = {}
        local i = 0
        for char in msg:gmatch"([%z\1-\127\194-\244][\128-\191]*)" do
                if(string.byte(char) >= 97 or string.byte(char) == 32) then
                        caseTable[i] = string.lower
                else
                        caseTable[i] = string.upper
                end

                i = i + 1
        end
end

local send = function(self, dest, reply, fuck)
        if(type(reply) == 'table') then
                math.randomseed(os.time())
                math.random(); math.random(); math.random()

                if(fuck) then
                        self:privmsg(dest, case(reply[math.random(1, #reply)]))
                else
                        self:privmsg(dest, reply[math.random(1, #reply)])
                end

        else
                if(fuck) then
                        self:privmsg(dest, case(reply))
                else
                        self:privmsg(dest, reply)
                end
        end
end

return {
                ["^:(%S+) PRIVMSG (%S+) :(.+)$"] = function(self, src, dest, msg)
                                -- block the bots own messages
                                if(self:srctonick(src) == self.config.nick) then return end
                                msg = trim(msg)
                                msg = msg:gsub('<.->%s+', '')
                                for pattern, reply in pairs(wordlist) do
                                        if(msg:match(pattern)) then
                                                buildCaseTable(msg)
                                                -- found a match, let's tail call our way out!
                                                return send(self, dest, reply)
                                        end
                                end

                                local tmp = msg:lower()
                                for pattern, reply in next, caseinsensitive do
                                        if(tmp:match(pattern)) then
                                                -- found a match, let's tail call our way out!
                                                return send(self, dest, reply)
                                        end
                                end

                                for pattern, reply in next, meh do
                                        if(tmp:match(pattern)) then
                                                buildCaseTable(msg)
                                                -- found a match, let's tail call our way out!
                                                return send(self, dest, reply, true)
                                        end
                                end
                        end,
}
