--幻魔の扉
--Illusion Gate
local s,id=GetID()
function s.initial_effect(c)
	--Destroy as many monsters your opponent controls as possible, then you can Special Summon 1 monster from your opponent's GY to your field, ignoring its Summoning conditions
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(Cost.PayLP(1/2))
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,0,LOCATION_GRAVE,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.spfilter),tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end