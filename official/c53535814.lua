--氷結界の浄玻璃
--Judge of the Ice Barrier
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Opponent loses 500 LP each time they pay LP
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PAY_LPCOST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.dmgcon)
	e2:SetOperation(s.dmgop)
	c:RegisterEffect(e2)
	--Shuffle targeted cards into the deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	--Change targeted monster to defense position
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCost(Cost.SelfBanish)
	e4:SetCondition(s.poscon)
	e4:SetTarget(s.postg)
	e4:SetOperation(s.posop)
	c:RegisterEffect(e4)
end
	--Lists "Ice Barrier" archetype
s.listed_series={SET_ICE_BARRIER}
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if not (re and re:IsActivated()) then return end
	e:GetHandler():RegisterFlagEffect(Duel.GetCurrentChain(),RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
end
	--If you control another "Ice Barrier" monster
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (ep==1-tp and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ICE_BARRIER),tp,LOCATION_MZONE,0,1,c)) then return false end
	return c:GetFlagEffect(Duel.GetCurrentChain())>0
end
	--Opponent loses 500 LP each time they pay LP
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local lp=Duel.GetLP(1-tp)
	Duel.SetLP(1-tp,lp-500)
end
	--Check for an "Ice Barrier" monster
function s.tdfilter(c)
	return c:IsSetCard(SET_ICE_BARRIER) and c:IsMonster() and c:IsAbleToDeck()
end
	--Check for an attack position monster
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,2,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,2,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,#g1,0,0)
end
	--Shuffle targeted cards into the deck
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
	--If you control an "Ice Barrier" monster
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ICE_BARRIER),tp,LOCATION_MZONE,0,1,nil)
end
	--Check for an attack position monster
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
	--Activation legality
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
	--Change targeted monster to defense position
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end