--ＲＥＩＮＦＯＲＣＥ！
--REINFORCE!
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 "Rescue-ACE" monster gain 1500 ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Set 1 "Rescue-ACE" Spell from your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RESCUE_ACE}
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsSetCard(SET_RESCUE_ACE) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_RESCUE_ACE),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_RESCUE_ACE),tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() or tc:IsControler(1-tp) then return end
	--Gains 1500 ATK/DEF
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	e1:SetValue(1500)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	tc:RegisterEffect(e2)
	--Unaffected by opponent's monster's effects
	local e3=e2:Clone()
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.immval)
	tc:RegisterEffect(e3)
	--Not destroyed the next time it would be destroyed by battle
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e4:SetCountLimit(1)
	e4:SetValue(function(_,_,r) return (r&REASON_BATTLE)==REASON_BATTLE end)
	tc:RegisterEffect(e4)
end
function s.immval(e,te)
	return te:IsMonsterEffect() and te:GetOwnerPlayer()==1-e:GetHandlerPlayer()
end
function s.setfilter(c)
	return c:IsSetCard(SET_RESCUE_ACE) and c:IsSpell() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.setfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsSSetable() then
		Duel.SSet(tp,tc)
	end
end