--ヴァルモニカの神奏－ヴァーラル
--Varar, Vaalmonican Concord
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 monsters, including a "Vaalmonica" Link Monster
	Link.AddProcedure(c,nil,2,2,s.matcheck)
	--Unaffected by non-"Vaalmonica" cards' effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return Duel.GetCounter(e:GetHandlerPlayer(),1,0,COUNTER_RESONANCE)>=6 end)
	e1:SetValue(s.immval)
	c:RegisterEffect(e1)
	--Gains additional attack for each Level 4 "Vaalmonica" monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Negate an opponent's Special Summon and destroy that monster(s), then remove 3 Resonance Counters from your field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_SPSUMMON)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==1-tp end)
	e3:SetTarget(s.negsumtg)
	e3:SetOperation(s.negsumop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_VAALMONICA}
s.counter_list={COUNTER_RESONANCE}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(SET_VAALMONICA,lc,sumtype,tp) and c:IsType(TYPE_LINK,lc,sumtype,tp)
end
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(s.matfilter,1,nil,lc,sumtype,tp)
end
function s.immval(e,te)
	local tc=te:GetHandler()
	local trig_loc,trig_setcodes=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SETCODES)
	if not Duel.IsChainSolving() or (tc:IsRelateToEffect(te) and tc:IsFaceup() and tc:IsLocation(trig_loc)) then
		return not tc:IsSetCard(SET_VAALMONICA)
	end
	for _,setcode in ipairs(trig_setcodes) do
		if (SET_VAALMONICA&0xfff)==(setcode&0xfff) and (SET_VAALMONICA&setcode)==SET_VAALMONICA then return false end
	end
	return true
end
function s.atkfilter(c)
	return c:IsLevel(4) and c:IsSetCard(SET_VAALMONICA) and c:IsFaceup()
end
function s.atkval(e)
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
end
function s.negsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,COUNTER_RESONANCE,3,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.negsumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	if Duel.Destroy(eg,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.RemoveCounter(tp,1,0,COUNTER_RESONANCE,3,REASON_EFFECT)
	end
end