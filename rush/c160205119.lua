--サイバー・エンド・ドラゴン
--Cyber End Dragon (Rush)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon Procedure
	Fusion.AddProcMixN(c,false,false,CARD_CYBER_DRAGON,3)
	--Piercing battle damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
end
s.material_setcode={0x93,0x1093}