-- ザ☆パワーアップ
-- The☆Power-Up
local s,id=GetID()
function s.initial_effect(c)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,LOCATION_MZONE,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.HintSelection(g)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		--Effect
		local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,LOCATION_MZONE,0,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffectRush(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
	end
end