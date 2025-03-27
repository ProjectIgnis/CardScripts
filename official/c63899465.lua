--Ｒ－ＡＣＥヘッドクオーター
--Rescue-ACE HQ
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--"Rescue-ACE" monsters you control gain 500 ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.atkcond)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_RESCUE_ACE))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Additional Normal summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_RESCUE_ACE))
	c:RegisterEffect(e4)
	--Shuffle 4 "Rescue-ACE" cards and draw 1
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.tdtg)
	e5:SetOperation(s.tdop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_RESCUE_ACE}
function s.atkcond(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)>0
end
function s.cfilter(c)
	return c:IsSetCard(SET_RESCUE_ACE) and c:IsAbleToDeck() and c:IsFaceup()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,4,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,4,4,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 or Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	local g=Duel.GetOperatedGroup()
	if not g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK|LOCATION_EXTRA) then return end
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	Duel.BreakEffect()
	Duel.Draw(tp,1,REASON_EFFECT)
end