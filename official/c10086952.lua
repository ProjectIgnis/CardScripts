--速攻召喚
--Quick Summon
local s,id=GetID()
function s.initial_effect(c)
	--Immediately after this effect resolves, Normal Summon/Set 1 monster. When you do, if your opponent controls a monster, you can Normal Summon a Level 5 or higher monster without Tributing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--During your Main Phase, if this card is in your GY, except the turn it was sent there: You can banish it; add 1 Level 5 or higher monster that can be Normal Summoned/Set from your Deck or GY to your hand, then immediately after this effect resolves, Tribute Summon it. You can only use this effect of "Quick Summon" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(aux.exccon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.nsfilter(c,no_tribute_chk,handler)
	if c:CanSummonOrSet(true,nil) then return true end
	if c:IsLevelAbove(5) and c:IsLocation(LOCATION_HAND) and no_tribute_chk then
		--When you do, if your opponent controls a monster, you can Normal Summon a Level 5 or higher monster without Tributing
		local e1=Effect.CreateEffect(handler)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCondition(function(e,c,minc) return c==nil or minc==0 end)
		c:RegisterEffect(e1)
		local res=c:IsSummonable(true,nil)
		e1:Reset()
		return res
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local no_tribute_chk=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,no_tribute_chk,e:GetHandler())
	end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local no_tribute_chk=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,no_tribute_chk,c):GetFirst()
	if not sc then return end
	if sc:IsLevelAbove(5) and sc:IsLocation(LOCATION_HAND) and no_tribute_chk then
		--When you do, if your opponent controls a monster, you can Normal Summon a Level 5 or higher monster without Tributing
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCondition(function(e,c,minc) return c==nil or minc==0 end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
	end
	Duel.SummonOrSet(tp,sc,true,nil)
end
function s.thfilter(c,tp)
	return c:IsLevelAbove(5) and c:IsSummonableCard() and Duel.CheckTribute(c,c:GetTributeRequirement()) and c:CanSummonOrSet(true,nil,1)
		and Duel.IsPlayerCanSummon(tp,SUMMON_TYPE_TRIBUTE,c) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if not sc then return end
	if sc:IsLocation(LOCATION_GRAVE) then Duel.HintSelection(sc) end
	if Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 then
		if sc:IsPreviousLocation(LOCATION_DECK) then Duel.ConfirmCards(1-tp,sc) end
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.SummonOrSet(tp,sc,true,nil,1)
	end
end