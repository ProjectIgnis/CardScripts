--マグネット・フォース・マイナス
--Magnet Force Minus
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START)
	e1:SetCost(aux.RemainFieldCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and not chkc:IsType(TYPE_MINUS) end
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.IsExistingTarget(aux.FaceupFilter(aux.NOT(Card.IsType),TYPE_MINUS),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,aux.FaceupFilter(aux.NOT(Card.IsType),TYPE_MINUS),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) or not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
		--Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		--Treated as Minus
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_MINUS)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		--Negate attack
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetRange(LOCATION_SZONE)
		e3:SetCode(EVENT_ADJUST)
		e3:SetCondition(s.nacon)
		e3:SetOperation(s.naop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
		--Must attack
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_EQUIP)
		e4:SetCode(EFFECT_SET_POSITION)
		e4:SetCondition(s.becon)
		e4:SetValue(POS_FACEUP_ATTACK)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e4)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_MUST_ATTACK)
		c:RegisterEffect(e5)
		local e6=e4:Clone()
		e6:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e6:SetValue(s.atkval)
		c:RegisterEffect(e6)
	else
		c:CancelToGrave(false)
	end
end
function s.nacon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local bc=ec:GetBattleTarget()
	return bc and bc:IsFaceup() and bc:IsType(TYPE_MINUS)
		and (Duel.GetCurrentPhase()<PHASE_DAMAGE or Duel.GetCurrentPhase()>PHASE_DAMAGE_CAL)
		and not Duel.GetAttacker():IsStatus(STATUS_ATTACK_CANCELED)
end
function s.naop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.NegateAttack()
end
function s.becon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_PLUS),e:GetHandler():GetEquipTarget():GetControler(),0,LOCATION_MZONE,1,nil)
end
function s.atkval(e,c)
	return c:IsFaceup() and c:IsType(TYPE_PLUS)
end