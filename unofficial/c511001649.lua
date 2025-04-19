--ダイナ・ベース (Anime)
--Dyna Base (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={75780818}
function s.cfilter(c,e,tp,ec)
	return c:IsRace(RACE_DINOSAUR) and c:IsReleasable()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,Group.FromCards(c,ec))
end
function s.spfilter(c,e,tp,mg)
	return c:IsCode(75780818) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,c,e,tp,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,c,e,tp,c):GetFirst()
	Duel.Release(Group.FromCards(c,tc),REASON_COST)
	Duel.SetTargetCard(tc)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		if sc:IsOriginalCode(511001648) then sc:CompleteProcedure() end
		local tc=Duel.GetFirstTarget()
		if tc then
			Duel.RaiseSingleEvent(sc,id,e,REASON_EFFECT,tp,tp,tc:GetTextAttack())
		end
	end
end