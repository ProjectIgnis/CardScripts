--六世壊根清浄
--Kashtira Big Bang
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Make both players banish monsters face-down so they control only 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmvcond)
	e1:SetTarget(s.rmvtg)
	e1:SetOperation(s.rmvop)
	c:RegisterEffect(e1)
	--Return 1 monster attached to the hand and Special Summon it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_KASHTIRA}
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_KASHTIRA)
end
function s.rmvcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if chk==0 then return (#g1>1 and g1:IsExists(Card.IsAbleToRemove,1,nil,tp,POS_FACEDOWN,REASON_RULE))
		or (#g2>1 and g2:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN,REASON_RULE)) end
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local p1=Duel.GetTurnPlayer() --used to make the turn player banish first
	local p2=1-Duel.GetTurnPlayer()
	local g1=Duel.GetFieldGroup(p1,LOCATION_MZONE,0)
	local rg1=g1:Filter(Card.IsAbleToRemove,nil,p1,POS_FACEDOWN,REASON_RULE)
	if #g1>1 and #rg1>0 then
		local ct=math.min(#g1-1,#rg1)
		Duel.Hint(HINT_SELECTMSG,p1,HINTMSG_REMOVE)
		local sg=rg1:Select(p1,ct,ct,nil)
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,PLAYER_NONE,p1)
	end
	local g2=Duel.GetFieldGroup(p2,LOCATION_MZONE,0)
	local rg2=g2:Filter(Card.IsAbleToRemove,nil,p2,POS_FACEDOWN,REASON_RULE)
	if #g2>1 and #rg2>0 then
		local ct=math.min(#g2-1,#rg2)
		Duel.Hint(HINT_SELECTMSG,p2,HINTMSG_REMOVE)
		local sg=rg2:Select(p2,ct,ct,nil)
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,PLAYER_NONE,p2)
	end
end
function s.thfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(SET_KASHTIRA) and c:GetOwner()==tp and c:IsAbleToHand()
end
function s.tgfilter(c,tp)
	if not (c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_KASHTIRA)) then return false end
	local g=c:GetOverlayGroup()
	return g:IsExists(s.thfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and s.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_OVERLAY)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local g=tc:GetOverlayGroup()
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=g:FilterSelect(tp,s.thfilter,1,1,nil,tp):GetFirst()
	if sc and Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.ShuffleHand(tp)
		if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end