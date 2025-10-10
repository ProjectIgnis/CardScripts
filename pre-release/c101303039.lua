--調獄神ジュノーラ
--Junora the Power Patron of Tuning
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 2 non-Tuner monsters (For this card's Synchro Summon, you can treat 1 monster in your center Main Monster Zone as a Tuner)
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),2,2,s.extratunerfilter)
	--Negate the effects of all face-up cards your opponent currently controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Make all monsters your opponent currently controls in the same columns as your "Elvennotes" monsters unable to be used as material for a Fusion, Synchro, Xyz, or Link Summon until the end of this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ELVENNOTES}
function s.extratunerfilter(c,scard,sumtype,tp)
	return c:IsSequence(2) and c:IsControler(tp)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,tp,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	for tc in g:Iter() do
		--Negate the effects of all face-up cards your opponent currently controls
		tc:NegateEffects(c,nil,true)
	end
end
function s.cannotmatfilter(c,tp)
	return c:GetColumnGroup():IsExists(s.elvennotesfilter,1,nil,tp)
end
function s.elvennotesfilter(c,tp)
	return c:IsSetCard(SET_ELVENNOTES) and c:IsFaceup() and c:IsControler(tp)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cannotmatfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cannotmatfilter,tp,0,LOCATION_MZONE,nil,tp)
	if #g==0 then return end
	local c=e:GetHandler()
	for tc in g:Iter() do
		Duel.HintSelection(tc)
		--All monsters your opponent currently controls in the same columns as your "Elvennotes" monsters cannot be used as material for a Fusion, Synchro, Xyz, or Link Summon until the end of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e1:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end