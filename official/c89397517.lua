--レジェンド・オブ・ハート
--Legend of Heart
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_LEGENDARY_DRAGON,SET_LEGENDARY_KNIGHT}
function s.cfilter(c,tp)
	return c:IsRace(RACE_WARRIOR) and Duel.GetMZoneCount(tp,c)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.CheckLPCost(tp,2000) and Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,tp) end
	Duel.PayLPCost(tp,2000)
	local sg=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,tp)
	Duel.Release(sg,REASON_COST)
end
function s.rmfilter(c)
	return c:IsSetCard(SET_LEGENDARY_DRAGON) and c:IsSpell() and c:IsAbleToRemove()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_LEGENDARY_KNIGHT) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local rmg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,nil)
	if #rmg==0 then return end
	local rmct=rmg:GetClassCount(Card.GetCode)
	local spg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,nil,e,tp)
	if #spg==0 then return end
	local spct=spg:GetClassCount(Card.GetCode)
	local ct=math.min(3,ft,spct,rmct)
	if ct==0 then return end
	local g=aux.SelectUnselectGroup(rmg,e,tp,1,ct,aux.dncheck,1,tp,HINTMSG_REMOVE)
	if #g==0 or Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==0 then return end
	ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
	local sg=aux.SelectUnselectGroup(spg,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #sg==0 then return end
	for tc in sg:Iter() do
		Duel.SpecialSummonStep(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	Duel.SpecialSummonComplete()
end