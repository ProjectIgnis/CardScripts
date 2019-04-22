--士気高揚
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--recover
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_EQUIP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.reccon)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
	--damage
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(eg:GetFirst():GetControler())
	return true
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,e:GetLabel(),1000)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(e:GetLabel(),1000,REASON_EFFECT)
end
function s.filter(c)
	return c:GetEquipTarget()~=nil or c:IsReason(REASON_LOST_TARGET)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.filter,nil)
	if #g==0 then return false end
	local flag=0
	if g:IsExists(Card.IsControler,1,nil,0) then flag=flag+1 end
	if g:IsExists(Card.IsControler,1,nil,1) then flag=flag+2 end
	e:SetLabel(({0,1,PLAYER_ALL})[flag])
	return true
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,e:GetLabel(),1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()~=1-tp then
		Duel.Damage(tp,1000,REASON_EFFECT,true)
	end
	if e:GetLabel()~=tp then
		Duel.Damage(1-tp,1000,REASON_EFFECT,true)
	end
	Duel.RDComplete()
end
