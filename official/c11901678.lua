--ブラック・デーモンズ・ドラゴン
--Black Skull Dragon
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_SUMMONED_SKULL,CARD_REDEYES_B_DRAGON)
end
s.listed_names={CARD_REDEYES_B_DRAGON}
s.material_setcode={SET_RED_EYES,SET_ARCHFIEND}