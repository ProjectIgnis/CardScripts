-- 渡来古討つデカコレーション
--Dekorelic Dessert
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Gain ATK and LP
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkcostfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsAbleToDeckOrExtraAsCost()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkcostfilter,tp,LOCATION_GRAVE,0,4,nil) end
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PYRO) and c:IsAttribute(ATTRIBUTE_EARTH)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,800)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.atkcostfilter,tp,LOCATION_GRAVE,0,4,4,nil)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		Duel.ShuffleDeck(tp)
		-- Effect
		local ag=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
		if #ag<1 then return end
		local c=e:GetHandler()
		for tc in ag:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(800)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
		end
		Duel.Recover(tp,800,REASON_EFFECT)
	end
end