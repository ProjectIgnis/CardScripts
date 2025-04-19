--Balance Blaster
--scripted by Shad3
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.cd)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.flag_op)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.flag_reg(c)
	if c:IsFaceup() and c:GetFlagEffect(id)==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetRange(LOCATION_MZONE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabel(c:GetAttack())
		e1:SetOperation(s.flag_raise)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
function s.flag_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.GetFieldGroup(0,LOCATION_MZONE,LOCATION_MZONE):ForEach(s.flag_reg)
end
function s.flag_raise(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==c:GetAttack() then return end
	Duel.RaiseEvent(Group.FromCards(c),EVENT_CUSTOM+id,e,REASON_EFFECT,rp,tp,e:GetLabel())
	e:SetLabel(c:GetAttack())
end
function s.cd(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(tp)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local val=ev-tc:GetAttack()
	if val~=0 then
		Duel.Damage(1-tp,math.abs(val),REASON_EFFECT)
		tc:ResetEffect(EFFECT_UPDATE_ATTACK,RESET_CODE)
		tc:ResetEffect(EFFECT_SET_ATTACK,RESET_CODE)
		tc:ResetEffect(EFFECT_SET_ATTACK_FINAL,RESET_CODE)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(val)
		tc:RegisterEffect(e1)
		while tc:GetAttack()~=ev do
			e1:SetValue(e1:GetValue()+ev-tc:GetAttack())
		end
	end
end