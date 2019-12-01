--オーバー・ザ・レインボー
--Rainbow Refraction
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
s.listed_names={79407975,79856792}
s.listed_series={0x1034}
function s.chainfilter(re,tp,cid)
	local rc=re:GetHandler()
	return not (re:IsActiveType(TYPE_MONSTER) and (rc:IsOriginalCodeRule(79407975) or rc:IsOriginalCodeRule(79856792)))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)~=0
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,nil,ft,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
