--嵐闘機爆流
--Stormrider Blast
--Scripted by Belisk.
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x580))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Untar
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.tgcon)
	e3:SetValue(s.tgval)
	c:RegisterEffect(e3)
	--Disable
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_FIELD)
	e3b:SetCode(EFFECT_DISABLE)
	e3b:SetRange(LOCATION_FZONE)
	e3b:SetTargetRange(0,LOCATION_MZONE)
	e3b:SetCondition(s.tgcon)
	e3b:SetTarget(s.distg)
	c:RegisterEffect(e3b)
	local e3c=e3b:Clone()
	e3c:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e3c)
	--must attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_MUST_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(s.atcon)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_MUST_BE_ATTACKED)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTarget(aux.TargetBoolFunction(s.atfilter))
	e6:SetCondition(s.atcon)
	e6:SetValue(1)
	c:RegisterEffect(e6)
end
function s.atkfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsSetCard(0x580)
end
function s.atkval(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_GRAVE,0,nil)
	return 400+300*g
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsLinkMonster() and c:IsSetCard(0x580)
end
function s.tgcon(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)==1
end
function s.tgval(e,re,rp)
	return rp~=e:GetHandlerPlayer() and not re:GetHandler():IsOnField()
end
function s.distg(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if #g>0 then 
		local link=g:GetFirst():GetLink()
		return c:IsLinkMonster() and not c:IsControler(tp) and c:GetLink()<=link
	else
		return false
	end
end
function s.atfilter(c)
	return s.cfilter(c) and c:GetSequence()>4
end
function s.atcon(e)
	return Duel.IsExistingMatchingCard(s.atfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end