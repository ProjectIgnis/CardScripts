--ワーム・グルス
--Worm Gulse
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0xf)
	--add counter
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.accon)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end
s.counter_place_list={0xf}
function s.atkval(e,c)
	return c:GetCounter(0xf)*300
end
function s.cfilter(c)
	return (c:GetPreviousPosition()&POS_FACEDOWN)~=0 and (c:GetPosition()&POS_FACEUP)~=0
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler())
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0xf,1)
end
