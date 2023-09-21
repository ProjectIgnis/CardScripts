--ヴァルモニカの神異－ゼブフェーラ
--Divine Oddity of Valmonica – Zebufera
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	--Link Summon procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),1,1)
	--Cannot be Link Summoned unless you have a Fiend Monster Card with 3 or more Resonance Counters in your Pendulum Zone
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetCost(s.spcost)
	c:RegisterEffect(e0)
	--Remove 3 Resonance Counters from your Pendulum Zone instead of destroying this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.reptg)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
	--Apply the effect of 1 "Valmonica" Normal Spell/Trap that is banished or in your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetTarget(s.cptg)
	e2:SetOperation(s.cpop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_VALMONICA}
s.counter_list={COUNTER_RESONANCE}
s.listed_names={id}
function s.spcfilter(c)
	return c:IsFaceup() and c:IsOriginalRace(RACE_FIEND) and c:GetCounter(COUNTER_RESONANCE)>=3
end
function s.spcost(e,c,tp,st)
	if (st&SUMMON_TYPE_LINK)~=SUMMON_TYPE_LINK then return true end
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_PZONE,0,1,nil)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and Duel.IsCanRemoveCounter(tp,1,0,COUNTER_RESONANCE,3,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RemoveCounter(tp,1,0,COUNTER_RESONANCE,3,REASON_EFFECT)
end
function s.cpfilter(c)
	return c:IsSetCard(SET_VALMONICA) and (c:IsNormalSpell() or c:IsNormalTrap())
		and c:IsFaceup() and c:CheckActivateEffect(false,true,false)
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.cpfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil):GetFirst()
	local eff=tc:CheckActivateEffect(false,true,false)
	e:SetProperty(EFFECT_FLAG_CARD_TARGET|eff:GetProperty())
	local tg=eff:GetTarget()
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	Duel.ClearOperationInfo(0)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local eff=tc:CheckActivateEffect(false,true,false)
	if not eff then return end
	local op=eff:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end