--デブリステーション
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={50400231,100000022}
function s.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
		and c:IsCode(50400231)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.spfilter(c,e,tp)
	return c:IsCode(100000022) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,true,false)
end
function s.gfilter(c)
	return c:IsCode(50400231) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.gfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.gfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or #g1~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=g1:Select(tp,2,2,nil)
	Duel.SendtoGrave(g2,REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,SUMMON_TYPE_FUSION,tp,tp,true,false,POS_FACEUP_ATTACK) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		end
	Duel.SpecialSummonComplete()
	tc:CompleteProcedure()
end
