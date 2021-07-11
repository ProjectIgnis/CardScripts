-- 陰陽封陣 
-- Onmyou Seal Array
local s,id=GetID()
function s.initial_effect(c)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup()	
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter),tp,0,LOCATION_MZONE,1,nil) end
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,4,4,nil)
	Duel.HintSelection(g)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		--Effect
		local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter),tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			local atk=tc:GetLevel()*(-200)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffectRush(e1)
		end
	end
end