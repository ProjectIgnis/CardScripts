--夢中のマリキータ
--Delirium Mariquita
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_INSECT) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAttackPos() and c:IsCanChangePosition() end
end
function s.filter(c)
	return c:IsFaceup() and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.insectfilter(c)
	return s.filter(c) and c:CanChangeIntoTypeRush(RACE_INSECT,2)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local c=e:GetHandler()
	if Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,0,0)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		g:GetFirst():RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		g:GetFirst():RegisterEffect(e2)
		if Duel.IsExistingMatchingCard(s.insectfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
			local dg=Duel.SelectMatchingCard(tp,s.insectfilter,tp,0,LOCATION_MZONE,1,1,nil)
			Duel.HintSelection(dg)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CHANGE_RACE)
			e3:SetValue(RACE_INSECT)
			e3:SetReset(RESETS_STANDARD_PHASE_END,2)
			dg:GetFirst():RegisterEffect(e3)
		end
	end
end