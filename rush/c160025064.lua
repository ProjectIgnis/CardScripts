--ブラスデスの落とし穴
--Brassdes Trap Hole
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	if c:IsLocation(LOCATION_GRAVE) then return c:IsCode(160218073) end
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsLevel(3)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return #eg==1 and tc:IsSummonPlayer(1-tp) and tc:IsLocation(LOCATION_MZONE) and tc:IsLevelBelow(8) and tc:IsType(TYPE_EFFECT)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
function s.filter2(c)
	return c:IsLevel(3) and c:IsFaceup()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter2),tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local tc2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter2),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc2 then
			Duel.HintSelection(tc2)
			-- Update ATK
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(700)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc2:RegisterEffect(e1)
		end
	end
end