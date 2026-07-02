--メンタルマスター
--Mind Master (pre-errata)
local s,id=GetID()
function s.initial_effect(c)
	--You can pay 800 Life Points and Tribute 1 Psychic-Type monster, except "Mind Master"; Special Summon 1 Level 4 or lower Psychic-Type monster from your Deck in Attack Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.costfilter(c)
	return c:IsRace(RACE_PSYCHIC) and not c:IsCode(id)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,800)
		and Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,aux.ReleaseCheckMMZ,nil) end
	Duel.PayLPCost(tp,800)
	local sg=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,aux.ReleaseCheckMMZ,nil)
	Duel.Release(sg,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_PSYCHIC) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
