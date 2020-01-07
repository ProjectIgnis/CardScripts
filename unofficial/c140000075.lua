--Adamantine Sword Revival
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={id+1}
function s.cfilter(c,tp)
	return c:IsRace(RACE_DRAGON) and c:IsPreviousLocation(LOCATION_GRAVE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cfilter,nil)
	return #g==1
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.filter(c,e,tp)
	return c:IsCode(id+1) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:Filter(s.cfilter,nil):GetFirst()
	if chk==0 then
		if e:GetLabel()~=1 or not tc then return false end
		e:SetLabel(0)
		local ft=Duel.GetLocationCount(tc:GetControler(),LOCATION_MZONE)
		return tc:IsReleasable() and ft>-1 and (ft>0 or tc:GetSequence()<5) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetTargetCard(tc)
	Duel.Release(tc,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local cc=Duel.GetFirstTarget()
	if not cc or Duel.GetLocationCount(cc:GetPreviousControler(),LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,cc:GetPreviousControler(),true,false,POS_FACEUP_ATTACK)>0 then
		Duel.RaiseSingleEvent(tc,id,e,REASON_EFFECT,tp,tp,cc:GetPreviousAttackOnField())
	end
end
