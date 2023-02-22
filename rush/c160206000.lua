--Meteor Black Dragon (Rush)
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_REDEYES_B_DRAGON,64271667)
end
s.listed_names={CARD_REDEYES_B_DRAGON}
s.material_setcode=SET_RED_EYES
