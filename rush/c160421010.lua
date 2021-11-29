-- ＣＡＮ－Ｍｅｌｏ：Ｄ
-- CAN-Melo:D
local s,id=GetID()
function s.initial_effect(c)
	-- Draw and send card from hand to GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
end
function s.tdfilter(c)
	return c:IsPosition(POS_FACEDOWN) and c:IsAbleToDeck()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.HintSelection(g)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_COST)>0 then
		--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g2=Duel.SelectMatchingCard(tp,s.tdfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.HintSelection(g2)
		if #g2>0 then
			local spg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
			if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and Duel.GetLP(tp)<Duel.GetLP(1-tp) and #spg>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g3=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
				if #g3>0 then
					Duel.SendtoHand(g,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,g)
				end
			end
		end
	end
end
function s.thfilter(c)
	return c:IsRace(RACE_PSYCHIC) and c:IsLevel(1) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end