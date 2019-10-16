--ハウスダストン
--House Duston
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x80}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE) then
		return c:GetReasonPlayer()~=tp and c:GetBattlePosition()&POS_FACEUP~=0
	end
	return rp~=tp and c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
function s.filter1(c,e,tp)
	return c:IsSetCard(0x80) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp)
end
function s.filter2(c,e,tp)
	return c:IsSetCard(0x80) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<=0
		or #g1<=0 or #g2<=0 then return end
	local sg1
	local sg2
	local tc
	repeat
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		sg1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		tc=sg1:GetFirst()
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		sg2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		tc=sg2:GetFirst()
		Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP)
		g1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
		g2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	until not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and #g1>0 and #g2>0
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)))
	Duel.SpecialSummonComplete()
end
