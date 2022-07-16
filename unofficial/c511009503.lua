--裁きの矢
--Judgment Arrows
local s,id=GetID()
function s.initial_effect(c)
	Card.SetUniqueOnField(c,1,0,id,LOCATION_SZONE)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetValue(s.zones)
	c:RegisterEffect(e1)
	--ATK increase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.adval)
	c:RegisterEffect(e2)
	--Check linked group
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.linkcon)
	e3:SetOperation(s.linkop)
	c:RegisterEffect(e3)
	--Destroy monsters when this leaves the field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.descon)
	e4:SetOperation(s.desop)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
function s.zones(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsLinkMonster),tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetLinkedZone(tp)>>8) & 0xff
end
function s.atkcon(e)
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
	local a=Duel.GetAttacker()
	local tp=e:GetHandlerPlayer()
	if a:IsControler(1-tp) then a=Duel.GetAttackTarget() end
	local lg=e:GetHandler():GetLinkedGroup()
	return a and lg:IsContains(a)
end
function s.atktg(e,c)
	local lg=e:GetHandler():GetLinkedGroup()
	return lg:IsContains(c) and c:IsLinkMonster() and (c==Duel.GetAttacker() or c==Duel.GetAttackTarget())
end
function s.adval(e,c)
	return c:GetAttack()
end
function s.linkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroup():GetCount()>0
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetLinkedGroup()
	if #g>0 then
		e:SetLabel(1)
		g:KeepAlive()
		local prevgroup=e:GetLabelObject()
		if prevgroup then
			prevgroup:DeleteGroup()
		end
		e:SetLabelObject(g)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local le=e:GetLabelObject()
	local g=le:GetLabelObject()
	if not g then return end
	Duel.Destroy(g,REASON_EFFECT)
	le:SetLabel(0)
	le:GetLabelObject():DeleteGroup()
	le:SetLabelObject(nil)
end