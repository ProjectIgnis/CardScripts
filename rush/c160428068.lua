--神の治療
--Master's Cure
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent normal/special summons a monster, take damage and shuffle monsters from the GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLevelAbove(7) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Recover(p,d,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter2),tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local tc2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter2),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc2 then
			Duel.HintSelection(tc2)
			-- Update ATK
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1000)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc2:RegisterEffect(e1)
		end
	end
end
function s.filter2(c)
	return c:IsRace(RACE_AQUA) and c:IsFaceup()
end
