--Ｆ．Ａ．ハングオンマッハ
--F.A. Hang On Mach
local s,id=GetID()
function s.initial_effect(c)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--immune
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a:SetCode(EVENT_CHAIN_SOLVING)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetOperation(s.immop)
	c:RegisterEffect(e2a)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.immval)
	e2:SetLabelObject(e2a)
	c:RegisterEffect(e2)
	--lv up
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_LVCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.lvcon)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	--redirect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.excon)
	e4:SetTarget(s.extg)
	e4:SetTargetRange(0,0xff)
	e4:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e4)
end
s.listed_series={0x107}
function s.atkval(e,c)
	return c:GetLevel()*300
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetLevel())
end
function s.immval(e,te)
	if te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER) and te:IsActivated() then
		local lv=e:GetLabelObject():GetLabel()
		local tc=te:GetHandler()
		if tc:GetRank()>0 then
			return tc:GetOriginalRank()<lv
		elseif tc:HasLevel() then
			return tc:GetOriginalLevel()<lv
		else return false end
	else return false end
end
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(0x107) and e:GetHandler():GetFlagEffect(1)>0
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_UPDATE_LEVEL)
		e4:SetValue(1)
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e4:SetRange(LOCATION_MZONE)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e4)
	end
end
function s.excon(e)
	return e:GetHandler():IsLevelAbove(7)
end
function s.extg(e,c)
	return c:GetOwner()~=e:GetHandlerPlayer() and Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end
