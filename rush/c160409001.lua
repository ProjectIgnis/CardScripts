-- 零撃竜ゼロギアス 
-- Zerogias the Nullstriking Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Targeted monster loses ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON) and c:IsLevelAbove(7) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0 and c:IsLevelBelow(8)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter),tp,0,LOCATION_MZONE,1,e:GetHandler()) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local dg=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
		if #dg>0 then
			Duel.HintSelection(dg)
			--Original ATK becomes 0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			dg:GetFirst():RegisterEffectRush(e1)
			--Attack up to thrice
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e2)
		end
	end
end
function s.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:GetAttack()>0 and c:IsLevelBelow(7)
end