--鎖付きブーメラン
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return false
		elseif e:GetLabel()==1 then
			return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup()
		else return false end
	end
	local b1=Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and Duel.GetTurnPlayer()~=tp
		and Duel.GetAttacker():IsLocation(LOCATION_MZONE) and Duel.GetAttacker():IsAttackPos()
		and Duel.GetAttacker():IsCanChangePosition() and Duel.GetAttacker():IsCanBeEffectTarget(e)
	local b2=e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local opt=0
	if b1 and b2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(opt)
	if opt==0 or opt==2 then
		Duel.SetTargetCard(Duel.GetAttacker())
	end
	if opt==1 or opt==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
		e:SetLabelObject(g:GetFirst())
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=e:GetLabel()
	if opt==0 or opt==2 then
		local tc=Duel.GetAttacker()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:CanAttack() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		end
	end
	if opt==1 or opt==2 then
		local tc=e:GetLabelObject()
		if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			Duel.Equip(tp,c,tc)
			c:CancelToGrave()
			--Atkup
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_EQUIP)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
			--Equip limit
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_EQUIP_LIMIT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(s.eqlimit)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e2)
		end
	end
end
function s.eqlimit(e,c)
	return c:GetControler()==e:GetOwnerPlayer()
end
