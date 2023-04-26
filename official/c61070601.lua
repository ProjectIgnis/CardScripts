--融合強兵
--Fusion Reinforcement
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon listed Fusion material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.exfilter(c,e,tp,filter_func)
	return c.material and c:IsType(TYPE_FUSION) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(filter_func,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,fc)
	if not (c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCode(table.unpack(fc.material))) then return false end
	if c:IsLocation(LOCATION_GRAVE) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	elseif c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local filter_func=s.spfilter
	if chk==0 then return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,filter_func) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local filter_func=aux.NecroValleyFilter(s.spfilter)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,filter_func):GetFirst()
	if not rc then return end
	Duel.ConfirmCards(1-tp,rc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,rc,e,tp,rc):GetFirst()
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		local ct=Duel.IsTurnPlayer(tp) and 2 or 1
		--Cannot attack
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3206)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,ct)
		sc:RegisterEffect(e1)
		--Its effects are negated
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,ct)
		sc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		sc:RegisterEffect(e3)
	end
	Duel.SpecialSummonComplete()
end