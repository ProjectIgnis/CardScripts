-- ＣＡＮ－Ｍｅｌｏ：Ｄ
--CAN - Melo:D
local s,id=GetID()
function s.initial_effect(c)
	-- Shuffle an opponent's face-down card to the deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsAbleToHand()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
end
function s.tdfilter(c)
	return c:IsPosition(POS_FACEDOWN) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_ONFIELD)
end
function s.thfilter(c)
	return c:IsRace(RACE_PSYCHIC) and c:IsLevel(1) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g1=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.HintSelection(g1,true)
	if #g1>0 and Duel.SendtoHand(g1,nil,REASON_COST)>0 then
		--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g2=Duel.SelectMatchingCard(tp,s.tdfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.HintSelection(g2,true)
		local spg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
		if #g2>0 and Duel.SendtoDeck(g2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and Duel.GetLP(tp)<Duel.GetLP(1-tp)
			and#spg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g3=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			if #g3>0 then
				Duel.SendtoHand(g3,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g3)
			end
		end
	end
end
