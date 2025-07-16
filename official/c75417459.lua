--拘束解除
--Release Restraint
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Gearfried the Swordmaster" from your hand or Deck
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
s.listed_names={423705,57046845} --"Gearfried the Iron Knight", "Gearfried the Swordmaster"
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsCode,1,false,aux.ReleaseCheckMMZ,nil,423705) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsCode,1,1,false,aux.ReleaseCheckMMZ,nil,423705)
	Duel.Release(g,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsCode(57046845) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local cost_chk=e:GetLabel()==-100
		e:SetLabel(0)
		return (cost_chk or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
	end
end