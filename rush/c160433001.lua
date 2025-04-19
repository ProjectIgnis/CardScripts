--竜騎士ガイア (Rush)
--Gaia the Dragon Champion (Rush)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--fusion material
	Fusion.AddProcMix(c,true,true,6368038,28279543)
end
s.material_setcode=SET_GAIA_THE_FIERCE_KNIGHT