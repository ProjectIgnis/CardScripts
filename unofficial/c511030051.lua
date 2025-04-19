--トポロジーナ・ギャッツビー
--Topologina Gatsbee
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand
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
	return c:IsMonster() and c:IsSetCard(0x57b) and c:IsAbleToGraveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.SendtoGrave(g,REASON_EFFECT)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zones=aux.GetMMZonesPointedTo(tp,nil,LOCATION_MZONE,0)
	if chk==0 then return zones>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zones) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zones=aux.GetMMZonesPointedTo(tp,nil,LOCATION_MZONE,0)
	if not c:IsRelateToEffect(e) or zones==0 then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zones)
end