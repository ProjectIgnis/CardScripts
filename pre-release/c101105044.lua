--先史遺産ヴィマナ
--Chronomaly Vimana
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_END_PHASE)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Negate activation
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
s.listed_series={0x70}
function s.gyfilter(c)
	return (c:IsSetCard(0x70) or c:IsType(TYPE_XYZ)) and c:IsType(TYPE_MONSTER)
		and c:GetAttack()>0 and not c:IsForbidden()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,1,0,LOCATION_GRAVE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_ATKCHANGE)
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_LEAVE_GRAVE)
	local c=e:GetHandler()
	local tc1,tc2=g1:GetFirst(),g2:GetFirst()
	if tc1:IsRelateToEffect(e) and tc1:IsFaceup()
		and not tc1:IsImmuneToEffect(e) and tc2:IsRelateToEffect(e) then
		--Increase ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.floor(tc2:GetAttack()/2))
		tc1:RegisterEffect(e1)
		Duel.BreakEffect()
		Duel.Overlay(c,tc2)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
		Duel.SendtoGrave(eg,REASON_EFFECT)
	end
end