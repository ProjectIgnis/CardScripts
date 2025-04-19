--フォビドゥン・サージカル・オペレーション
--Malevolent Malpractice
--Scripted by the Razgriz, pyrQ, Naim and Larry126
local s,id=GetID()
function s.initial_effect(c)
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop)
end
function s.rmvfilter1(c,e,tp)
	return c:IsLevelBelow(2) and c:IsAbleToRemove() and aux.SpElimFilter(c,true)
		and Duel.IsExistingMatchingCard(s.rmvfilter2,tp,LOCATION_GRAVE|LOCATION_MZONE,0,2,nil,e,tp,c)
end
function s.rmvfilter2(c,e,tp,tc)
	local lv=tc:GetLevel()
	local code=tc:GetCode()
	return c:IsCode(code) and c:IsLevel(lv) and c:IsAbleToRemove() and aux.SpElimFilter(c,true)
		and Duel.GetMZoneCount(tp,Group.FromCards(c,tc))>1 and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,2,nil,e,tp,lv)
end
function s.spfilter1(c,e,tp,lv)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevel(lv)
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,2,nil,e,tp,lv,c:GetCode())
end
function s.spfilter2(c,e,tp,lv,code)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevel(lv) and c:IsCode(code)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==1 and sg:GetClassCount(Card.GetLevel)==1
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.IsExistingMatchingCard(s.rmvfilter1,tp,LOCATION_GRAVE|LOCATION_MZONE,0,2,nil,e,tp)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--opd check and ask if you want to activate the skill or not
	if Duel.GetFlagEffect(tp,id)>0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	--opd register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--check if skill is negated
	if aux.CheckSkillNegation(e,tp) then return end
	--Special Summon
	local g1=Duel.GetMatchingGroup(s.rmvfilter1,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil,e,tp)
	if #g1<=0 then return end
	local rg=aux.SelectUnselectGroup(g1,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE)
	local lv=rg:GetFirst():GetLevel()
	if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		local g2=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK,0,nil,e,tp,lv)
		if #g2<=0 then return end
		local sg=aux.SelectUnselectGroup(g2,e,tp,2,2,s.rescon,1,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end