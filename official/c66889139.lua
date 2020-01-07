--竜騎士ガイア
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,6368038,28279543)
end
s.material_setcode=0xbd
