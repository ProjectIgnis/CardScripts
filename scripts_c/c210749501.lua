--Wattbat
function c210749501.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(210749501,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c210749501.target)
	e1:SetOperation(c210749501.operation)
	c:RegisterEffect(e1)
end
function c210749501.wattfilter(c)
	return c:IsSetCard(0xe) and c:IsAbleToDeck()
end
function c210749501.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c210749501.filter(chkc) end
	local g=Duel.GetMatchingGroup(c210749501.wattfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetCount()>=2 end--Confirms 2+ Watt cards in GY
end
--Return 2 Watt cards to deck, then stun up to 2 opponent cards until end of next turn
function c210749501.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c210749501.wattfilter,tp,LOCATION_GRAVE,0,nil)
	local rg=g:Select(tp,2,2,nil)--User select 2 Watt cards in GY
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)--Opponent cards (can replace aux.TRUE with c210749501.stunfilter)
	if Duel.SendtoDeck(rg,nil,2,REASON_EFFECT) and dg:GetCount()>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(210749501,1))
		local sg=dg:Select(tp,0,2,nil)--User select opponent cards
		Duel.HintSelection(sg)
		if sg:GetCount()>0 then
			local tc=sg:GetFirst()
			local c=e:GetHandler()
			while tc do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)--Stun each selected card
				e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,2)--Reset at the second end phase
				tc:RegisterEffect(e1)
				tc=sg:GetNext()
			end
		end
	end
end
--OPTIONAL FILTER TO SPECIFY WHICH CARDS MAY BE SELECTED
--function c210749501.stunfilter(c)
--	return c:IsType(TYPE_EFFECT) or c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP) or c:IsFacedown()
--end