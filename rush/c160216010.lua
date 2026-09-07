--メェ～界の王姫メェ～グちゃん
--Royal Princess of the Wooly Wunderworld - Miss Mutton
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,CARD_MEEEG_CHAN,1,s.matfilter,2)
end
s.named_material={CARD_MEEEG_CHAN}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsRace(RACE_BEAST,scard,sumtype,tp) and c:IsType(TYPE_NORMAL)
end