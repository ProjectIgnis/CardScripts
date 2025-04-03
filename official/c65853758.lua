--ヤミー★リデンプション
--Yummy★Redemption
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(TIMING_DAMAGE_STEP)
	e0:SetCondition(aux.StatChangeDamageStepCondition)
	c:RegisterEffect(e0)
	--Monsters your opponent controls lose 200 ATK for each LIGHT Beast monster you control and in your GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Draw 1 card, then place 1 card from your hand on the bottom of the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.drwcon)
	e2:SetTarget(s.drwtg)
	e2:SetOperation(s.drwop)
	c:RegisterEffect(e2)
	--Switch control of 1 "Yummy" monster you control and 1 monster your opponent controls
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,id)
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.ctrltg)
	e3:SetOperation(s.ctrlop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_YUMMY}
function s.atkvalfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST) and c:IsFaceup()
end
function s.atkval(e,c)
	return -200*Duel.GetMatchingGroupCount(s.atkvalfilter,e:GetHandlerPlayer(),LOCATION_MZONE|LOCATION_GRAVE,0,nil)
end
function s.drwconfilter(c,tp)
	return c:IsSynchroSummoned() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST) and c:IsSummonPlayer(tp) and c:IsFaceup()
end
function s.drwcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.drwconfilter,1,nil,tp)
end
function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	Duel.ShuffleHand(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.BreakEffect()
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
function s.selffilter(c,tp)
	return c:IsSetCard(SET_YUMMY) and c:IsAbleToChangeControler() and c:IsFaceup() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
function s.oppfilter(c,tp)
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.selffilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and Duel.IsExistingTarget(s.oppfilter,tp,0,LOCATION_MZONE,1,nil,1-tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g1=Duel.SelectTarget(tp,s.selffilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g2=Duel.SelectTarget(tp,s.oppfilter,tp,0,LOCATION_MZONE,1,1,nil,1-tp)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,tp,0)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==2 then
		Duel.SwapControl(tg:GetFirst(),tg:GetNext())
	end
end