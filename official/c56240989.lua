--エヴォルド・カシネリア
--Evoltile Cansinerio
local s,id=GetID()
function s.initial_effect(c)
	--Register a flag when it destroys a monster by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(function(e) e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1) end)
	c:RegisterEffect(e1)
	--Special Summon 2 Level 6 or lower FIRE Dinosaur monsters from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e2:SetCost(aux.SelfTributeCost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_DINOSAUR)
		and c:IsCanBeSpecialSummoned(e,SUMMON_BY_EVOLTILE,tp,false,false)
end
function s.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==1
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return #g>=2 and Duel.GetMZoneCount(tp,e:GetHandler())>=2
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g<2 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,1,tp,HINTMSG_SPSUMMON)
	for tc in sg:Iter() do
		Duel.SpecialSummonStep(tc,SUMMON_BY_EVOLTILE,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,fid)
		--Their effects are negated
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		Duel.SpecialSummonComplete()
	end
	sg:KeepAlive()
	--Banish them during the End Phase
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PHASE+PHASE_END)
	e0:SetCountLimit(1)
	e0:SetLabel(fid)
	e0:SetLabelObject(sg)
	e0:SetCondition(s.rmcon)
	e0:SetOperation(s.rmop)
	Duel.RegisterEffect(e0,tp)
end
function s.rmfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.rmfilter,nil,e:GetLabel())
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end