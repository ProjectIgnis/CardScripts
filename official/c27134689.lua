--マスター・オブ・OZ
--Master of Oz
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,42129512,78613627)
end