--ティンクル・ファイブスター
--Five Star Twilight
--OCG/TCG converted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={44632120,71036835,7021574,34419588,CARD_KURIBOH}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g==1 and g:GetFirst():IsLevel(5) and g:GetFirst():IsFaceup()
end
function s.cfilter(c,ft,tp)
	return c:IsLevel(5) and (ft>=5 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>=4 and Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,ft,tp) end
	local rg=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,ft,tp)
	Duel.Release(rg,REASON_COST)
end
function s.filter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local locs=LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE
	if chk==0 then
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<5 then return false end
		e:SetLabel(0)
		return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
			and Duel.IsExistingMatchingCard(s.filter,tp,locs,0,1,nil,e,tp,44632120)
			and Duel.IsExistingMatchingCard(s.filter,tp,locs,0,1,nil,e,tp,71036835)
			and Duel.IsExistingMatchingCard(s.filter,tp,locs,0,1,nil,e,tp,7021574)
			and Duel.IsExistingMatchingCard(s.filter,tp,locs,0,1,nil,e,tp,34419588)
			and Duel.IsExistingMatchingCard(s.filter,tp,locs,0,1,nil,e,tp,CARD_KURIBOH)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,5,tp,locs)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local locs=LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<5 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,locs,0,nil,e,tp,44632120)
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,locs,0,nil,e,tp,71036835)
	local g3=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,locs,0,nil,e,tp,7021574)
	local g4=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,locs,0,nil,e,tp,34419588)
	local g5=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,locs,0,nil,e,tp,CARD_KURIBOH)
	if #g1>0 and #g2>0 and #g3>0 and #g4>0 and #g5>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg3=g3:Select(tp,1,1,nil)
		sg1:Merge(sg3)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg4=g4:Select(tp,1,1,nil)
		sg1:Merge(sg4)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg5=g5:Select(tp,1,1,nil)
		sg1:Merge(sg5)
		for tc in aux.Next(sg1) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			e1:SetValue(1)
			tc:RegisterEffect(e1,true)
		end
		Duel.SpecialSummonComplete()
	end
end