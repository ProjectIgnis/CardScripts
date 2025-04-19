--レッカメテオ
--Destructurtle Meteor
local s,id=GetID()
function s.initial_effect(c)
	--Position change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsRace(RACE_REPTILE) and c:IsFaceup()
end
function s.filter2(c)
	return c:IsLevelBelow(8) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,2,nil)
		and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter2),tp,0,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,2,2,nil)
	local g2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter2),tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	for tc in g1:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetValue(-1500)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end