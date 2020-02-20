--アスレチック・サーカス
--Acrobatic Circus
local s,id=GetID()

function s.initial_effect(c)
	Duel.LoadCardScript("c301.lua")
end

s.af="a"

s.tableAction = {
150000024,
150000033,
150000042,
150000071
}