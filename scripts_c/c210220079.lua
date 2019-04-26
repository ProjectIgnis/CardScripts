--HDi・エクシーズ 
--Hyper-Dimension Xyz
--Created and scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 and Duel.CheckLPCost(tp,1500) end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabelObject(e)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e1,tp)
	e:SetLabelObject(e1)
	Duel.PayLPCost(tp,1500)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabelObject()~=se
end
function s.filter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xyzfilter(c,mg,ct)
	return c:IsXyzSummonable(mg,ct,ct)
end
function s.matcon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==1 and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,sg,#sg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and ct>1 and aux.SelectUnselectGroup(mg,e,tp,2,ct,s.matcon,0) end
	local g=aux.SelectUnselectGroup(mg,e,tp,2,ct,s.matcon,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.filter2,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	Duel.SpecialSummonComplete()
	if Duel.GetLocationCountFromEx(tp,tp,g)<=0 then return end
	Duel.BreakEffect()
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
	if #xyzg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
	Duel.XyzSummon(tp,xyz,g)
	local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	local xg=Duel.GetMatchingGroup(s.setcfilter,tp,LOCATION_EXTRA,0,nil,xyz:GetCode())
	if #xg>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local xc=xg:Select(tp,1,1,nil)
		Duel.ConfirmCards(1-tp,xc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sc=sg:Select(tp,1,1,nil):GetFirst()
		Duel.SSet(tp,sc)
		Duel.ConfirmCards(1-tp,sc)
		e:GetLabelObject():Reset()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(sc:GetActivateEffect())
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.sumlimit)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.setcfilter(c,cd)
	return c:IsType(TYPE_XYZ) and aux.IsCodeListed(c,cd) and not c:IsCode(cd) and c:IsFacedown()
end
function s.setfilter(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(0x95) and c:IsSSetable()
end
