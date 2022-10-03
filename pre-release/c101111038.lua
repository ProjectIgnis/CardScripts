-- 氷水啼エジル・ギュミル
-- Icejade Aegirine Gymir
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 1 WATER Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),1,1,Synchro.NonTuner(nil),1,99)
	-- Apply monster protection
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetOperation(s.immop)
	c:RegisterEffect(e1)
	-- Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.rmfilter(c,code)
	return c:IsFaceup() and c:IsCode(code) and c:IsAbleToRemove()
end
function s.immtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ch=Duel.GetCurrentChain()
	if ch<=1 then return end
	local chp,chcode=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_CODE)
	if chp~=1-tp or not chcode then return end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD|LOCATION_GRAVE)
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Monsters cannot be destroyed or banished opponent's effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(aux.indoval)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.remtg)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2),RESET_PHASE|PHASE_END,1)
	local ch=Duel.GetCurrentChain()
	if ch<=1 then return end
	local chp,chcode=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_CODE)
	if chp~=1-tp or not chcode then return end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,nil,chcode)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.remtg(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and rp==1-tp and r==REASON_EFFECT
end
function s.spconfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end