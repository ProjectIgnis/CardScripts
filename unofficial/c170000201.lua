--Legend of Heart
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={110000101}
function s.costfilter(c,code)
	return c:IsCode(code) and c:IsAbleToRemoveAsCost()
end
function s.rescon(ct)
	return  function(sg,e,tp,mg)
				return aux.ChkfMMZ(3-ct)(sg,e,tp,mg) and sg:IsExists(s.chk,1,nil,sg,Group.CreateGroup(),1784686,46232525,11082056)
			end
end
function s.chk(c,sg,g,code,...)
	if not c:IsCode(code) then return false end
	local res
	if ... then
		g:AddCard(c)
		res=sg:IsExists(s.chk,1,g,sg,g,...)
		g:RemoveCard(c)
	else
		res=true
	end
	return res
end
function s.cfilter(c,ft,e,tp,g)
	local ftct=(c:GetSequence()<5 and c:IsControler(tp)) and 1 or 0
	local mg=g:Clone()
	mg:RemoveCard(c)
	return c:IsRace(RACE_WARRIOR) and (c:IsFaceup() or c:IsControler(tp)) and aux.SelectUnselectGroup(mg,e,tp,3,3,s.rescon(ftct),0)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g1=Duel.GetMatchingGroup(s.costfilter,tp,0x1f,0,nil,1784686)
	local g2=Duel.GetMatchingGroup(s.costfilter,tp,0x1f,0,nil,46232525)
	local g3=Duel.GetMatchingGroup(s.costfilter,tp,0x1f,0,nil,11082056)
	local g=g1:Clone()
	g:Merge(g2)
	g:Merge(g3)
	if chk==0 then return ft>-4 and Duel.CheckLPCost(tp,1000) and #g1>0 and #g2>0 and #g3>0 
		and Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,ft,e,tp,g) end
	Duel.PayLPCost(tp,1000)
	local rg=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,ft,e,tp,g)
	g:Sub(rg)
	local c=rg:GetFirst()
	local ct=(c:GetSequence()<5 and c:IsControler(tp)) and 1 or 0
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon(ct),1,tp,HINTMSG_REMOVE)
	Duel.Release(rg,REASON_COST)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function s.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=2 then return false end
		e:SetLabel(0)
		return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
			and Duel.IsExistingMatchingCard(s.spfilter,tp,0x33,0,1,nil,e,tp,80019195)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,0x33,0,1,nil,e,tp,85800949)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,0x33,0,1,nil,e,tp,84565800)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,3,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,0x33,0,nil,e,tp,80019195)
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,0x33,0,nil,e,tp,85800949)
	local g3=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,0x33,0,nil,e,tp,84565800)
	if #g1>0 and #g2>0 and #g3>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg2=g2:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg3=g3:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		sg1:Merge(sg3)
		local tc=sg1:GetFirst()
		for tc in aux.Next(sg1) do
			Duel.SpecialSummonStep(tc,0,tp,tp,true,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
		Duel.SpecialSummonComplete()
	end
	Duel.BreakEffect()
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,48179391,110000100,110000101)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	Duel.BreakEffect()
	Duel.Destroy(g,REASON_EFFECT)
	Duel.SendtoGrave(g,REASON_EFFECT)
end
