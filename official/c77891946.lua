--エクソシスター・バディス
--Exosister Vadis
--Scripted by Hel
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(Cost.PayLP(800))
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_EXOSISTER}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_EXOSISTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.lfilter1,1,nil,sg)
end
function s.lfilter1(c,sg)
	return sg:IsExists(s.lfilter2,1,c,c)
end
function s.lfilter2(c,tc)
	return c:ListsCode(tc:GetCode())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and aux.SelectUnselectGroup(mg,e,tp,2,2,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local mg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #mg<2 then return end
	local g1=aux.SelectUnselectGroup(mg,e,tp,2,2,s.rescon,1,tp,HINTMSG_SPSUMMON)
	if #g1>1 then
		local fid=c:GetFieldID()
		local tc=g1:GetFirst()
		for tc in aux.Next(g1) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1,fid)
		end
		Duel.SpecialSummonComplete()
		g1:KeepAlive()
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCategory(CATEGORY_TODECK)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g1)
		e1:SetCondition(s.tdcon)
		e1:SetOperation(s.tdop)
		Duel.RegisterEffect(e1,tp)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE|PHASE_END)
		e1:SetTarget(s.splimit)
		e1:SetTargetRange(1,0)
		Duel.RegisterEffect(e1,tp)
		--Lizard check
		aux.addTempLizardCheck(c,tp,s.lizfilter)
	end
end
function s.tdfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.tdfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.tdfilter,nil,e:GetLabel())
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.splimit(e,c)
	return not c:IsSetCard(SET_EXOSISTER) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalSetCard(SET_EXOSISTER)
end