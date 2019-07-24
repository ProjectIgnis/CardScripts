--ヒヤリ＠イグニスター
--Hiyari @Ignister
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(293542,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsType(TYPE_LINK) and c:IsFaceup() and c:GetSequence()>4
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.lkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
function s.zonefilter(tp)
	local lg=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_MZONE,0,nil)
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
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zones=s.zonefilter(tp)
	if not e:GetHandler():IsRelateToEffect(e) or zones==0 then return end
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP,zones)
end
