--インサイド・ロール・アウト
--Inside Roll Out

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 of opponent's monsters lose 400 ATK per pyro monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsLevelAbove(5)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.filter(c)
	return c:IsFaceup()
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
end
	--Make 1 of opponent's monsters lose 500 ATK
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	--Effect
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		g:GetFirst():RegisterEffectRush(e1)
		if Duel.GetLP(tp)-Duel.GetLP(tp)>=2000 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			g:GetFirst():RegisterEffectRush(e1)
		end
	end
end