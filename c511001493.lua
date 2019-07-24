--Shining Reborn
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.spcheck(ft)
	return function(sg,tp)
				return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
					or sg:IsExists(aux.FilterBoolFunction(Card.IsInMainMZone,1-tp),ft,nil)
			end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if chk==0 then return ft>-2 and Duel.CheckReleaseGroupCost(tp,nil,2,false,s.spcheck(-ft+1),nil) end
	local sg=Duel.SelectReleaseGroupCost(tp,nil,2,2,false,s.spcheck(-ft+1),nil)
	Duel.Release(sg,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0 
			and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp)
	end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sp=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
		if #sp>0 and Duel.SpecialSummon(sp,0,tp,1-tp,false,false,POS_FACEUP)>0 then
			local setg=Duel.GetMatchingGroup(Card.IsSSetable,1-tp,0,LOCATION_HAND,nil)
			if #setg>0 and Duel.SelectYesNo(tp,aux.Stringid(60082869,0)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
				local sg=setg:Select(tp,1,1,nil)
				Duel.SSet(1-tp,sg:GetFirst())
			end
		end
	end
end
