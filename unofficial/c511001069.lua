--妖仙郷の眩暈風 (Anime)
--Dizzying Winds of Yosen Village (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--todeck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_TO_HAND_REDIRECT)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetTarget(s.tdtg)
	e2:SetValue(LOCATION_DECKSHF)
	c:RegisterEffect(e2)
end
s.listed_names={93368494}
s.listed_series={0xb3}
function s.filter(c)
	return c:IsFaceup() and c:IsCode(93368494)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.tdtg(e,c)
	return (c:IsFacedown() or not c:IsSetCard(0xb3)) and c:IsReason(REASON_EFFECT)
end
