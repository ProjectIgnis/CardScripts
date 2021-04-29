--実力伯仲
--Stand-Off

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsType(TYPE_EFFECT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1:IsRelateToEffect(e) and tc1:IsFaceup() and tc2:IsRelateToEffect(e) and tc2:IsFaceup() then
		local a=0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		if not tc1:IsDisabled() then
			tc1:RegisterEffect(e1)
			tc1:RegisterEffect(e2)
			a=a+1
		end
		if not tc2:IsDisabled() then
			local e3=e1:Clone()
			local e4=e2:Clone()
			tc2:RegisterEffect(e3)
			tc2:RegisterEffect(e4)
			a=a+1
		end
		if tc1:IsDefensePos() or tc2:IsDefensePos() or a~=2 then return end
		Duel.BreakEffect()
		s.reg(c,tc1,tc2)
		s.reg(c,tc2,tc1)
	end
end
function s.reg(c,tc1,tc2)
	tc1:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(s.posop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc1:RegisterEffect(e1)
	--Cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(3000)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(s.effcon)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetLabelObject(tc2)
	tc1:RegisterEffect(e2)
	--Cannot change their battle positions
	local e3=e2:Clone()
	e3:SetDescription(3313)
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	tc1:RegisterEffect(e3)
	--Cannot attack
	local e4=e2:Clone()
	e4:SetDescription(3206)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	tc1:RegisterEffect(e4)
	--Unaffected by other card effects
	local e5=e2:Clone()
	e5:SetDescription(3100)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(s.efilter)
	tc1:RegisterEffect(e5)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)~=0 and not c:IsPosition(POS_FACEUP_ATTACK) then
		c:ResetFlagEffect(id)
	end
end
function s.effcon(e)
	return e:GetHandler():GetFlagEffect(id)~=0 and e:GetLabelObject():GetFlagEffect(id)~=0
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end