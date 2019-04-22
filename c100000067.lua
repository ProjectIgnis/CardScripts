--グランド・コア
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--battle indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetCountLimit(1)
	e3:SetValue(s.valcon)
	c:RegisterEffect(e3)
end
function s.valcon(e,re,r,rp)
	return r&REASON_BATTLE>0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,5,tp,0x13)
end
function s.filter(c,code,e,tp)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	Duel.Destroy(sg,REASON_EFFECT)
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,0x13,0,nil,4545683,e,tp)
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,0x13,0,nil,100000062,e,tp)
	local g3=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,0x13,0,nil,100000063,e,tp)
	local g4=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,0x13,0,nil,100000064,e,tp)
	local g5=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,0x13,0,nil,100000065,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=5 and #g1>0 and #g2>0 and #g3>0 
		and #g4>0 and #g5>0 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc1=g1:Select(tp,1,1,nil):GetFirst()
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		local tc2=g2:Select(tp,1,1,nil):GetFirst()
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
		local tc3=g3:Select(tp,1,1,nil):GetFirst()
		Duel.SpecialSummonStep(tc3,0,tp,tp,false,false,POS_FACEUP)
		local tc4=g4:Select(tp,1,1,nil):GetFirst()
		Duel.SpecialSummonStep(tc4,0,tp,tp,false,false,POS_FACEUP)
		local tc5=g5:Select(tp,1,1,nil):GetFirst()
		Duel.SpecialSummonStep(tc5,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
	end
end
