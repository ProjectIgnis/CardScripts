--妖仙郷の眩暈風
--Dizzying Winds of Yosen Village
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
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_TO_HAND_REDIRECT)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.tdtg)
	e2:SetCondition(s.tdcon)
	e2:SetValue(LOCATION_DECKSHF)
	c:RegisterEffect(e2)
end
s.listed_series={SET_YOSENJU}
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(6) and c:IsSetCard(SET_YOSENJU)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.tdtg(e,c)
	return (c:IsFacedown() or not c:IsSetCard(SET_YOSENJU)) and c:IsReason(REASON_EFFECT)
end
function s.tdcon(e)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,nil,SET_YOSENJU)
end