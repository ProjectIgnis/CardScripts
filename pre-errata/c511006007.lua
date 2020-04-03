--Blue-Eyes Ultimate Dragon (Pre-Errata)
--青眼の究極竜
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcCodeRep(c,CARD_BLUEEYES_W_DRAGON,3,true,true)
end
s.listed_names={CARD_BLUEEYES_W_DRAGON}