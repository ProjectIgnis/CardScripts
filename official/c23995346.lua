--青眼の究極竜
--Blue-Eyes Ultimate Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,CARD_BLUEEYES_W_DRAGON,3)
end
s.material_setcode=0xdd
s.listed_name={CARD_BLUEEYES_W_DRAGON}
