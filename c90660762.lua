--メテオ・ブラック・ドラゴン
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,true,true,CARD_REDEYES_B_DRAGON,64271667)
end
s.listed_names={CARD_REDEYES_B_DRAGON}
s.material_setcode=0x3b
