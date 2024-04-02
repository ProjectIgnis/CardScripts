--花牙縫い
--Shadow Flower Sewing
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PLANT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) end
end
function s.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter,tp),tp,0,LOCATION_MZONE,1,e:GetHandler()) end
end
function s.cfilter2(c)
	return c:IsMonster() and c:IsType(TYPE_NORMAL) and c:IsLevel(5)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsType(TYPE_NORMAL) and c:IsNotMaximumModeSide()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--requirement
	if Duel.DiscardDeck(tp,3,REASON_COST)>2 then
		--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter,tp),tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			g=g:AddMaximumCheck()
			Duel.HintSelection(g,true)
			local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_GRAVE,0,nil)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*(-100))
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			g:GetFirst():RegisterEffect(e1)
			local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
			if Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_GRAVE,0,1,nil) and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end