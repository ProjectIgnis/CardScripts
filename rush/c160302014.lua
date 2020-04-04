--Counteroffensive Dragonstrike
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,e,tp)
	return c:IsReason(REASON_BATTLE) and c:IsRace(RACE_DRAGON) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	if chk==0 then return eg:IsExists(s.cfilter,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- effect
	local tc=Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil)
	if tc:IsRelateToEffect(e) then
		Duel.BreakEffect()
		if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
