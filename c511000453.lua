--Crystal Seal
Duel.LoadScript("c419.lua")
local s,id=GetID()
function s.initial_effect(c)
	aux.AddPersistentProcedure(c,1,aux.FilterBoolFunction(Card.IsFaceup),CATEGORY_POSITION+CATEGORY_DISABLE,nil,nil,0x1c0,nil,nil,s.target)
	--disable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.PersistentTargetFilter)
	c:RegisterEffect(e1)
	--cannot attack
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e4)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e5)
	local e6=e1:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	c:RegisterEffect(e6)
	local e7=e1:Clone()
	e7:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	c:RegisterEffect(e7)
	--Destroy
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCode(511001762)
	e8:SetCondition(s.descon)
	e8:SetOperation(s.desop)
	c:RegisterEffect(e8)
	--indestructable
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e9:SetRange(LOCATION_SZONE)
	e9:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e9:SetValue(s.indval)
	c:RegisterEffect(e9)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,tc,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
end
function s.efilter(e,re,rp)
	return e:GetHandlerPlayer()~=rp
end
function s.cfilter(e,c)
	return c==e:GetHandler()
end
function s.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
function s.cfilter(c,ec)
	local val=0
	if c:GetFlagEffect(284)>0 then val=c:GetFlagEffectLabel(284) end
	return c:IsFaceup() and ec:IsHasCardTarget(c) and c:GetAttack()~=val
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,e:GetHandler())
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function s.indval(e,re,tp)
	return e:GetOwner()~=re:GetOwner()
end
