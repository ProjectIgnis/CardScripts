--Black Luster Soljersey - Envoy of the Drying
-- カオス・ソルジャージ －乾燥の使者－
local s,id=GetID()
function s.initial_effect(c)	
	--Shuffle 1 level 8 monster from opponent's field to deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.tdcost)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
end
function s.tdcostfilter(c)
	return c:IsDefense(500) and c:IsAbleToDeckOrExtraAsCost()
end
function s.tdcostrescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetAttribute)==#sg 
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local cg=Duel.GetMatchingGroup(s.tdcostfilter,tp,LOCATION_GRAVE,0,nil)
		return aux.SelectUnselectGroup(cg,e,tp,2,2,s.tdcostrescon,0)
	end
end
--shuffle up to 2 spellcaster to the deck
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.tdfilter),tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
end
function s.tdfilter(c)
	return c:IsLevelBelow(8) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	--requirement
	local g=Duel.GetMatchingGroup(s.tdcostfilter,tp,LOCATION_GRAVE,0,nil)
	local cg=aux.SelectUnselectGroup(g,e,tp,2,2,s.thcostrescon,1,tp,HINTMSG_TODECK)
	if Duel.SendtoDeck(cg,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.tdfilter),tp,0,LOCATION_MZONE,1,1,nil)
		g=g:AddMaximumCheck()
		Duel.HintSelection(g)
		if #g>0 then
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			--Cannot attack directly
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3207)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end