--ハイドライブ・ブースター
--Hydradrive Booster
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.hspcon)
	c:RegisterEffect(e1)
end
function s.hspcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(0,LOCATION_MMZONE,LOCATION_MMZONE)==0
end