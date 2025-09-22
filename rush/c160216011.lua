--メェ～界パイロウール
--Wooly Wunderworld Pyro Wool
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,160009004,2)
end