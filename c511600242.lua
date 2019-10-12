--SRカールターボ
--Speedroid Karuturbo
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
end
s.listed_series={0x2016}
function s.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2016)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
