--ブラック・デーモンズ・ドラゴン
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_SUMMONED_SKULL,CARD_REDEYES_B_DRAGON)
end
s.listed_names={CARD_REDEYES_B_DRAGON}
s.material_setcode={0x3b,0x45}
