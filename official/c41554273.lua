--ダイナミスト・ラッシュ
--Dinomist Rush
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Dinomist" monster from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DINOMIST}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_DINOMIST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		sc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
		--Destroy it during the End Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		e1:SetLabelObject(sc)
		Duel.RegisterEffect(e1,tp)
		--Unaffected by other cards' effects
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3100)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetValue(s.efilter)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)>0 then
		return true
	else
		e:Reset()
		return false
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Destroy(tc,REASON_EFFECT)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetHandler()
end