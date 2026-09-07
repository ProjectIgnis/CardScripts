--剛鬼死闘
--Gouki Cage Match
local s,id=GetID()
local COUNTER_GOUKI_CAGE_MATCH=0x46
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_GOUKI_CAGE_MATCH)
	--When this card is activated: Place 3 counters on this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If your "Gouki" monster destroys an opponent's monster by battle: Remove 1 counter from this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.rmvcountercon)
	e2:SetOperation(s.rmvcounterop)
	c:RegisterEffect(e2)
	--Once per turn, at the end of the Battle Phase, if the last of these counters has been removed this way: You can Special Summon as many "Gouki" monsters as possible with different names from your hand and/or Deck, then place 3 counters on this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	e3:SetCountLimit(1)
	c:RegisterEffect(e3)
end
s.listed_series={SET_GOUKI}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanAddCounter(tp,COUNTER_GOUKI_CAGE_MATCH,3,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,tp,COUNTER_GOUKI_CAGE_MATCH)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(COUNTER_GOUKI_CAGE_MATCH,3)
	end
end
function s.rmvcountercon(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetBattleMonster(tp)
	if not (bc and bc:IsStatus(STATUS_OPPO_BATTLE)) then return false end
	if bc:IsRelateToBattle() then
		return bc:IsSetCard(SET_GOUKI) and bc:IsControler(tp)
	else
		return bc:IsPreviousSetCard(SET_GOUKI) and bc:IsPreviousControler(tp)
	end
end
function s.rmvcounterop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:RemoveCounter(tp,COUNTER_GOUKI_CAGE_MATCH,1,REASON_EFFECT) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE,1)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetCounter(COUNTER_GOUKI_CAGE_MATCH)==0 and c:HasFlagEffect(id,3)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_GOUKI) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp)
	if #tg==0 then return end
	local c=e:GetHandler()
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=aux.SelectUnselectGroup(tg,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		c:AddCounter(COUNTER_GOUKI_CAGE_MATCH,3)
		c:ResetFlagEffect(id)
	end
end