--レベル・タックス
--Level Tax
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--affect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE) 
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--30459350 chk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(id)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsLevelAbove(5) and c:GetFlagEffect(id)==0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,0,0xff,0xff,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SUMMON_COST)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCost(s.costchk)
		e1:SetOperation(s.costop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetLabelObject(e1)
		e2:SetCode(EFFECT_FLIPSUMMON_COST)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetLabelObject(e2)
		e3:SetCode(EFFECT_SPSUMMON_COST)
		tc:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
		e4:SetCode(EVENT_ADJUST)
		e4:SetRange(0xff)
		e4:SetLabelObject(e3)
		e4:SetOperation(s.resetop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
function s.costchk(e,c,tp)
	local atk=c:GetAttack()
	e:SetLabel(atk)
	return Duel.IsPlayerAffectedByEffect(c:GetControler(),id) and Duel.CheckLPCost(c:GetControler(),atk)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.PayLPCost(c:GetControler(),e:GetLabel())
	e:SetLabel(0)
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerAffectedByEffect(tp,id) then
		local e3=e:GetLabelObject()
		local e2=e3:GetLabelObject()
		local e1=e2:GetLabelObject()
		e:Reset()
		e1:Reset()
		e2:Reset()
		e3:Reset()
		e:GetHandler():ResetFlagEffect(id)
	end
end
