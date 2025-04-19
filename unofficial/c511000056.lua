--二重波紋
--Double Ripple
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={25862681,2403771}
s.tempcard=nil
function s.filter1(c,ntg,tp,e)
	if c:IsFacedown() or c:GetLevel()<=0 or not c:IsType(TYPE_TUNER) then return false end
	s.tempcard=c
	local res=aux.SelectUnselectGroup(ntg,e,tp,nil,nil,s.rescon,0)
	s.tempcard=nil
	return res
end
function s.rescon(sg,e,tp,mg)
	sg:AddCard(s.tempcard)
	local res=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,25862681,sg)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,2403771,sg)
		and sg:CheckWithSumEqual(Card.GetLevel,7,#sg,#sg)
	sg:RemoveCard(s.tempcard)
	return res
end
function s.filter2(c)
	return c:IsFaceup() and c:GetLevel()>0 and not c:IsType(TYPE_TUNER) 
end
function s.spfilter(c,e,tp,code,sg)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local nt=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and aux.CheckSummonGate(tp,2) and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil,nt,tp,e) 
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if not aux.CheckSummonGate(tp,2) then return end
	local nt=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,nt,tp,e):GetFirst()
	if tc then
		s.tempcard=tc
		local sg=aux.SelectUnselectGroup(nt,e,tp,nil,nil,s.rescon,1,tp,HINTMSG_TOGRAVE,s.rescon)
		s.tempcard=nil
		sg:AddCard(tc)
		local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,2403771,sg)
		local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,25862681,sg)
		if #g1>0 and #g2>0 and Duel.SendtoGrave(sg,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg1=g1:Select(tp,1,1,nil)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg2=g2:Select(tp,1,1,nil)
			sg1:Merge(sg2)
			Duel.BreakEffect()
			local sgc=sg1:GetFirst()
			for sgc in aux.Next(sg1) do
				Duel.SpecialSummonStep(sgc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
			Duel.SpecialSummonComplete()
		end
	end
end