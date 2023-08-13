--レジェンド・ストライク
--Legend Strike
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 monster from the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={160206005}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,300) end
end
function s.filter(c,e,tp)
	return ((c:IsLevel(4) and c:IsAttackBelow(1600)) or (c:IsType(TYPE_NORMAL) and c:IsLegend())) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.PayLPCost(tp,300)
	--Effect
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.HintSelection(tc,true)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local dg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
		if #dg>0 and (tc:IsCode(160206005) or (tc:IsLegend() and tc:IsType(TYPE_NORMAL))) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local sg=dg:Select(tp,1,1,nil)
			Duel.HintSelection(sg,true)
			Duel.BreakEffect()
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end