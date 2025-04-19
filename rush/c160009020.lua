--羊界プランユー
--Wooly Wonderland Planewe
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Set from your GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160009044,160009055,CARD_MEEEG_CHAN}
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsType(TYPE_NORMAL)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.setfilter(c)
	return c:IsCode(160009044,160009055) and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g==0 or Duel.SSet(tp,g)==0 then return end
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_MEEEG_CHAN),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Recover(tp,600,REASON_EFFECT)
	end
end