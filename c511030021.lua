--天装法典
--Armatos Lex
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--negate direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--return to deck and hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9409625,1)) --Empty Machine
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.thdtg)
	e3:SetOperation(s.thdop)
	c:RegisterEffect(e3)
	--tribute to draw
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(67616300,0)) --Chicken Game
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.drcost)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
end
s.listed_series={0x578}
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return Duel.GetAttackTarget()==nil
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end
function s.tdfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x578) and c:IsAbleToHand()
end
function s.thdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.GetFlagEffect(tp,id)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g2=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.thdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local ex1,tg1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	local ex2,tg2=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	if tg1 and tg1:GetFirst():IsRelateToEffect(e) and Duel.SendtoDeck(tg1,nil,0,REASON_EFFECT)~=0
		and tg1:GetFirst():IsLocation(LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
		Duel.SendtoHand(tg2,nil,REASON_EFFECT)
	end
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,false,nil,nil,0x578)
		and Duel.GetFlagEffect(tp,id)==0 end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,1,false,nil,nil,0x578)
	Duel.Release(g,REASON_COST)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.Draw(p,d,REASON_EFFECT)
	end
end