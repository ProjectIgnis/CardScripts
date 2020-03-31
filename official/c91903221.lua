--エヴォルド・エルギネル
local s,id=GetID()
function s.initial_effect(c)
	--draw & search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_RELEASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x304e}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
function s.filter1(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToDeck()
end
function s.filter2(c)
	return c:IsSetCard(0x304e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
	local g1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_HAND,0,nil)
	local g2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK,0,nil)
	if #g1>0 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tg1=g1:Select(tp,1,1,nil)
		Duel.ConfirmCards(1-tp,tg1)
		Duel.SendtoDeck(tg1,nil,2,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg2=g2:Select(tp,1,1,nil)
		Duel.SendtoHand(tg2,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg2)
	end
end
