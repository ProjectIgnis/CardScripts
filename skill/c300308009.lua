--"Invitation" to the Society
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	--Flip this card over at the start of the Duel
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
s.listed_names={49306994} --White Veil
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Check for "White Veil" activations
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(0x5f)
	e0:SetCondition(s.checkcon)
	e0:SetOperation(function(_,tp) Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end)
	Duel.RegisterEffect(e0,tp)
	--Take control of an opponent's monster equipped with "White Veil"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_EQUIP)
	e1:SetRange(0x5f)
	e1:SetCondition(s.ctrlcon)
	e1:SetOperation(s.ctrlop)
	Duel.RegisterEffect(e1,tp)
	--Can only attack with monsters equipped with "White Veil" the turn you activate "White Veil"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(0x5f)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetFlagEffect(tp,id)>0 end)
	e2:SetTarget(function(e,c) return not c:GetEquipGroup():IsExists(Card.IsCode,1,nil,49306994) end)
	Duel.RegisterEffect(e2,tp)
end
function s.wvfilter(c,tp)
	return c:IsCode(49306994) and c:IsControler(tp)
end
function s.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.wvfilter,1,nil,tp) 
end
function s.ctrlcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local tc=rc:GetEquipTarget()
	return rc:IsCode(49306994) and rc:IsControler(tp) and tc:IsControler(1-tp)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local tc=rc:GetEquipTarget()
	if rc:IsCode(49306994) and rc:IsControler(tp) and tc:IsControler(1-tp) then
		local e1=Effect.CreateEffect(rc)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetValue(tp)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(e1)
	end
end
