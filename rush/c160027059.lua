--セインティック・ピルグリム
--Saintick Pilgrim
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Add from your GY to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={160027032,160027064,160027067}
function s.thfilter(c)
	return c:IsCode(160027032,160027064,160027067) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.tdfilter(c)
	return c:IsAbleToDeck() and c:IsMonster()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local tg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
			Duel.HintSelection(tg)
			if Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WIND)>0 and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_STZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				local tc=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,0,LOCATION_STZONE,1,1,nil):GetFirst()
				if not tc then return end
				Duel.ConfirmCards(tp,tc)
				if tc:IsTrap() then
					Duel.BreakEffect()
					Duel.Destroy(tc,REASON_EFFECT)
				end
			end
		end
	end
end