--幻奏の音女スコア
local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetDescription(aux.Stringid(24040093,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.filter(c,e,tp,eg,ep,ev,re,r,rp)
	local check=false
	local te=c:GetActivateEffect()
	if not te then return false end
	local tg=te:GetTarget()
	local op=te:GetOperation()
	if (not tg and op) or tg(e,tp,eg,ep,ev,re,r,rp,0) then
		check=true
	end
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove() and te:GetCode()==EVENT_FREE_CHAIN
		and Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE,0,1,c,c:GetCode(),check)
end
function s.filter2(c,code,check,e,tp,eg,ep,ev,re,r,rp)
	local te=c:GetActivateEffect()
	if not te then return false end
	local tg=te:GetTarget()
	local op=te:GetOperation()
	return c:IsCode(code) and c:IsType(TYPE_SPELL) and c:IsAbleToRemove() and (check or (not tg and op) or tg(e,tp,eg,ep,ev,re,r,rp,0))
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp):GetFirst()
	local te=tc:GetActivateEffect()
	if not te then return false end
	local tg=te:GetTarget()
	local op=te:GetOperation()
	if (not tg and op) or tg(e,tp,eg,ep,ev,re,r,rp,0) then
		check=true
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,tc,tc:GetCode(),check,e,tp,eg,ep,ev,re,r,rp)
	g2:AddCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,2,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=2 then return end
	if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)>1 then
		local tc=tg:GetFirst()
		local te=tc:GetActivateEffect()
		local tg=te:GetTarget()
		local op=te:GetOperation()
		if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
		Duel.BreakEffect()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
end
