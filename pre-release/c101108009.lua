-- スケアクロー・アストラ
-- Scareclaw Astra
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetValue(s.hspval)
	c:RegisterEffect(e1)
	-- Multiple attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end
s.listed_series={0x279}
s.sclawfilter=aux.FilterFaceupFunction(Card.IsSetCard,0x279)
function s.hspval(e,c)
	local tp=c:GetControler()
	local zone=0
	local lg=Duel.GetMatchingGroup(s.sclawfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(lg) do
		zone=(zone|tc:GetColumnZone(LOCATION_MZONE,1,1,tp))
	end
	return 0,zone&0x1f
end
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(aux.AND(s.sclawfilter,Card.IsDefensePos),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.atktg(e,c)
	return s.sclawfilter(c) and c:IsInExtraMZone()
end
function s.atkval(e)
	local g=Duel.GetMatchingGroup(aux.AND(s.sclawfilter,Card.IsDefensePos),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)-1
end