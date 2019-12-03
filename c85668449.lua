--脳開発研究所
--Brain Research Lab
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x4)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--extra summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,LOCATION_HAND+LOCATION_MZONE)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PSYCHIC))
	e2:SetOperation(s.esop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(s.ctcon)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	--lpcost replace
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EFFECT_LPCOST_REPLACE)
	e4:SetCondition(s.lrcon)
	e4:SetOperation(s.lrop)
	c:RegisterEffect(e4)
	--damage
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_LEAVE_FIELD_P)
	e5:SetOperation(s.damp)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetOperation(s.damop)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
s.counter_list={0x4}
function s.esop(e,tp,eg,ep,ev,re,r,rp,c)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():GetFlagEffect(id)~=0
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x4,1)
	eg:GetFirst():ResetFlagEffect(id)
end
function s.lrcon(e,tp,eg,ep,ev,re,r,rp)
	if tp~=ep then return false end
	local lp=Duel.GetLP(ep)
	if lp<ev then return false end
	if not re or not re:IsHasType(0x7e0) then return false end
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_MZONE) and rc:IsRace(RACE_PSYCHIC)
end
function s.lrop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x4,1)
end
function s.damp(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x4)
	e:SetLabel(ct)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	if ct>0 then
		Duel.Damage(tp,ct*1000,REASON_EFFECT)
	end
end
