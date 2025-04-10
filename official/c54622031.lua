--金色の魔象
--Great Mammoth of Goldfine
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,29491031,66672569)
end