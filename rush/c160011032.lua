--シャドウ・バイヤー
--Shadow Buyer
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Increase Level by 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():HasLevel() and Duel.GetMatchingGroupCountRush(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(g)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		--Effect
		local c=e:GetHandler()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			local ct=Duel.GetMatchingGroupCountRush(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
			c:UpdateLevel(ct,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,c)
		end
	end
end

