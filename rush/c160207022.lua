--超魔犬ロペロ
--Supreme Dog Ropero
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Make itself unable to be destroyed by battle or opponent's traps, make a 2nd attack on monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) and Duel.IsExistingMatchingCard(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,2,nil) end
end
function s.thfilter(c)
	return (c:IsCode(160207024,160207026) or (c:IsLevel(10) and c:IsType(TYPE_MAXIMUM))) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.PayLPCost(tp,500)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,2,2,nil)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
	--Effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3000)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetValue(1)
	e1:SetReset(RESETS_STANDARD_PHASE_END,2)
	c:RegisterEffect(e1)
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g2>0 then
			Duel.HintSelection(g2,true)
			Duel.BreakEffect()
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
		end
	end
end
