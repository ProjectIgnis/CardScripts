--Angel Tear
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.costfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,sg,e,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkcost=e:GetLabel()==1 and true or false
	local rg=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if chkcost then
			e:SetLabel(0)
			return ft>-4 and #rg>3 and aux.SelectUnselectGroup(rg,e,tp,4,4,s.rescon,0)
		else
			return ft>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		end
	end
	if chkcost then
		local g=aux.SelectUnselectGroup(rg,e,tp,4,4,s.rescon,1,tp,HINTMSG_REMOVE)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
