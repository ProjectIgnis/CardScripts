--ムーンバリア
--Light Wing Shield
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_DISABLED)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--Detach cost change
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.rcon)
	e2:SetOperation(s.rop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_UTOPIA}
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_UTOPIA)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return true end
	local op=0
	if Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	end
	if op==0 then
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(s.endop)
	else
		e:SetCategory(CATEGORY_ATKCHANGE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
		e:SetOperation(s.atkop)
	end
end
function s.endop(e,tp,eg,ep,ev,re,r,rp)
	local turnp=Duel.GetTurnPlayer()
	Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE|PHASE_END,1)
	Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE|PHASE_END,1,1)
	Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE|PHASE_END,1)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,turnp)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack()*2)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_COST)~=0 and re:IsActivated()
		and re:IsActiveType(TYPE_XYZ) and re:GetHandler():IsSetCard(SET_UTOPIA)
		and e:GetHandler():IsAbleToRemoveAsCost()
		and ep==e:GetOwnerPlayer() and ev==1
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	return Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end