-- 名刺しの命死交換
--Business Card Barrage

local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 of opponent's level 7 or lower monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={160006024}
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(160006024)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,e:GetHandler())
	if chk==0 then return #dg>0 end
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(7)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local dg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,e:GetHandler())
	if #dg==0 then return end
	local sg=dg:Select(tp,1,1,nil)
	sg=sg:AddMaximumCheck()
	Duel.HintSelection(sg)
	if Duel.Destroy(sg,REASON_EFFECT)>0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.spfilter(c,e,sp)
	return c:IsRace(RACE_MACHINE) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end