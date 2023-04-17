--サイバー・ツイン・ドラゴン (Rush)
--Cyber Twin Dragon (Rush)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon Procedure
	Fusion.AddProcMixN(c,true,true,CARD_CYBER_DRAGON,2)
	--Extra attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
s.material_setcode={SET_CYBER,SET_CYBER_DRAGON}