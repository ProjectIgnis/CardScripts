--青眼の究極竜
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,CARD_BLUEEYES_W_DRAGON,3)
end
s.material_setcode=0xdd
