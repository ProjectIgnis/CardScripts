--Power Gravity
--パワー・グラヴィティ
--  By Shad3

local scard,s_id=s,id

function scard.initial_effect(c)
	--Global Reg
	if not scard.gl_chk then
		scard.gl_chk=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(scard.flag_op)
		Duel.RegisterEffect(ge1,0)
	end
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CUSTOM+s_id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(scard.cd)
	e1:SetTarget(scard.tg)
	e1:SetOperation(scard.op)
	c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(scard.sds_cd)
	e2:SetOperation(scard.sds_op)
	c:RegisterEffect(e2)
	--flag check
	local e3=Effect.CreateEffect(c)
	e3:SetCode(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCondition(scard.sds_flagcd)
	e3:SetOperation(scard.sds_flagop)
	c:RegisterEffect(e3)
end

function scard.flag_reg(c)
	if c:IsFaceup() and c:GetFlagEffect(s_id)==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetRange(LOCATION_MZONE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabel(c:GetAttack())
		e1:SetOperation(scard.flag_raise)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(s_id,RESET_EVENT+RESETS_STANDARD,0,1,0)
	end
end

function scard.flag_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.GetFieldGroup(0,LOCATION_MZONE,LOCATION_MZONE):ForEach(scard.flag_reg)
end

function scard.flag_raise(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==c:GetAttack() then return end
	Duel.RaiseEvent(Group.FromCards(c),EVENT_CUSTOM+s_id,e,REASON_EFFECT,tp,tp,math.abs(e:GetLabel()-c:GetAttack()))
	e:SetLabel(c:GetAttack())
end

function scard.cd(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
end

function scard.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function scard.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.Equip(tp,c,tc)
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_SET_ATTACK_FINAL)
		e0:SetValue(0)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		re:GetHandler():RegisterEffect(e0)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(function(e,c) return c==e:GetLabelObject() end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(ev)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end

function scard.sds_cd(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:GetFlagEffectLabel(s_id)==1
end

function scard.sds_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

function scard.sds_flagcd(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and Duel.GetAttacker()==ec
end

function scard.sds_flagop(e,tp,eg,ep,ev,re,r,rp)
	ec:SetFlagEffectLabel(s_id,1)
end