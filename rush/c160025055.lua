--Ｒ・プロテクト
--Rising Protect
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 monster from the grave to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
end
function s.monsterfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(3) and c:IsDefense(1000)
end
function s.thfilter(c)
	return (c:IsCode(160025062) or s.monsterfilter(c)) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local td=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,1,1,c)
	if Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_COST)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	local tg=aux.SelectUnselectGroup(sg,1,tp,1,2,s.rescon,1,tp)
	local ct=Duel.SendtoHand(tg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tg)
	if Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,LOCATION_MZONE,0,1,1,nil)
		Duel.HintSelection(g2)
		local tc=g2:GetFirst()
		if tc then
			--Protection
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetDescription(3001)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
		end
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,160025062)<2 and sg:FilterCount(s.monsterfilter,nil)<2
end