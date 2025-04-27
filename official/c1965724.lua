--怒れるもけもけ
--Mokey Mokey Smackdown
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Register if a face-up Fairy monster you control is destroyed while you control "Mokey Mokey"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.regcon)
	e1:SetOperation(function(e) return e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1) end)
	c:RegisterEffect(e1)
	--The ATK of each "Mokey Mokey" you control will become 3000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e2:SetTarget(function(e,c) return c:IsCode(27288416) and c:IsFaceup() end)
	e2:SetValue(3000)
	c:RegisterEffect(e2)
end
s.listed_names={27288416} --"Mokey Mokey"
function s.regconfilter(c,tp)
	return c:IsPreviousRaceOnField(RACE_FAIRY) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():HasFlagEffect(id) and eg:IsExists(s.regconfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,27288416),tp,LOCATION_MZONE,0,1,nil)
end