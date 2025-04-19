--嵐を呼ぶサンダービート
--Thunderbeetle Storm

local s,id=GetID()
function s.initial_effect(c)
	--Destroy all of opponent's level 8 or lower effect monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER) and c:IsLevelBelow(4)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.cfilter),tp,LOCATION_MZONE,0,3,nil)
end
function s.desfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsLevelBelow(8) and c:IsFaceup() and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_SUMMON)
			Duel.RegisterEffect(e2,tp)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e3:SetDescription(aux.Stringid(id,0))
			e3:SetReset(RESET_PHASE|PHASE_END)
			e3:SetTargetRange(1,0)
			Duel.RegisterEffect(e3,tp)
			Duel.AddNoTributeCheck(c,tp,id,0,1,0)
		end
	end
end