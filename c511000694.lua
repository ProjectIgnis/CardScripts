--Excalibur
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--double original atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.atkop)
	e2:SetLabel(0)
	c:RegisterEffect(e2)
	--Destroy on Draw
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DRAW)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	--Skip Draw Phase
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(1,0)
	e5:SetCode(EFFECT_SKIP_DP)
	c:RegisterEffect(e5)
	--check for doubling
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(id)
	c:RegisterEffect(e6)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep~=c:GetControler() then return end
	Duel.Destroy(c,REASON_EFFECT)
end
function s.chkfilter(c,eq)
	local ec=c:GetEquipTarget()
	return c:IsHasEffect(id) and ec and ec==eq and not c:IsDisabled()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local eq=c:GetEquipTarget()
	local g=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_SZONE,LOCATION_SZONE,c,eq)
	if eq and c:GetFlagEffect(id+1)==0 and e:GetLabel()~=#g+1 then
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
		local tc=g:GetFirst()
		while tc do
			tc:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD_DISABLE,0,0)
			tc=g:GetNext()
		end
		local atk=eq:GetBaseAttack()
		for i=1,#g+1 do
			atk=atk*2
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		e:SetLabel(#g+1)
	end
end
