--アルケミカライズ・オーブ
--Alchemicalize Orb
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon Procedure
	Fusion.AddProcMix(c,true,true,s.matfilter,aux.FilterBoolFunctionEx(Card.IsRace,RACE_THUNDER|RACE_AQUA))
	--Give Piercing damage to a Warrior monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.matfilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_PYRO,fc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_FIRE,fc,sumtype,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.filter(c)
	return c:IsFaceup() and c:CanGetPiercingRush()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,1,nil) end
end
function s.placefilter(c)
	return c:IsSpellTrap() and c:IsAbleToDeck()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		--Piercing
		tc:AddPiercing(RESETS_STANDARD_PHASE_END,e:GetHandler())
		local dg=Duel.GetMatchingGroup(s.placefilter,tp,0,LOCATION_ONFIELD,nil)
		if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=dg:Select(tp,1,1,nil)
			if #sg==0 then return end
			Duel.HintSelection(sg)
			Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end