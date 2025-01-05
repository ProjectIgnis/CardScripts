--強制進化
--Evo-Force
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Evolsaur" monster and treat it as summoned by the effect of an "Evoltile" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_EVOLTILE,SET_EVOLSAUR}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,false,aux.ReleaseCheckMMZ,nil,SET_EVOLTILE) end
	local rg=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,1,false,aux.ReleaseCheckMMZ,nil,SET_EVOLTILE)
	Duel.Release(rg,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_EVOLSAUR) and c:IsCanBeSpecialSummoned(e,SUMMON_BY_EVOLTILE,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==100 then
			e:SetLabel(0)
			return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		else
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		end
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_BY_EVOLTILE,tp,tp,false,false,POS_FACEUP)
	end
end