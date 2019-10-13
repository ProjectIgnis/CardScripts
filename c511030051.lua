--トポロジーナ・ギャッツビー
--Topologina Gatsbee
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={0x57b}
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x57b) and c:IsAbleToGraveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST,e:GetHandler())
end
function s.zonefilter(tp)
	local lg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_LINK)
	local zone=0
	for tc in aux.Next(lg) do
		zone=zone|tc:GetLinkedZone()
	end 
	return zone
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zones=s.zonefilter(tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zones) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zones=s.zonefilter(tp)
	if not e:GetHandler():IsRelateToEffect(e) or zones==0 then return end
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP,zones)
end