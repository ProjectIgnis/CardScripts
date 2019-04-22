--ダイスエット
--Dicette
--scripted by andre
local s,id=GetID()
function s.initial_effect(c)
	--you turn effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)
	--his turn effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return tp == Duel.GetTurnPlayer()
end
function s.filter(c)
	return c:IsAbleToRemove() and aux.SpElimFilter(c)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,6,nil) end
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local r = Duel.TossDice(tp,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg = Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,r,r,nil)
	if #rg > 0 then
		local rm = Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		if rm == r and r == 1 then
			Duel.BreakEffect()
			Duel.DiscardDeck(tp,6,REASON_EFFECT)
		end
	end
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return tp ~= Duel.GetTurnPlayer()
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.IsPlayerCanDiscardDeck(tp,6) end
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local r = Duel.TossDice(tp,1)
	local dd = Duel.DiscardDeck(tp,r,REASON_EFFECT)
	if r == 6 and dd == r then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg = Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil)
		if #rg > 0 then
			Duel.BreakEffect()
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT) 
		end
	end
end

