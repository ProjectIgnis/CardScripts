--肉弾戦闘
--Hand-to-Hand Combat
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function() return Duel.IsBattlePhase() end)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetCondition(s.regcon)
		e1:SetOperation(s.regop1)
		Duel.RegisterEffect(e1,0)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_NEGATED)
		e2:SetCondition(s.regcon)
		e2:SetOperation(s.regop2)
		Duel.RegisterEffect(e2,0)
	end)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsBattlePhase()
end
function s.regop1(e,tp,eg,ep,ev,re,r,rp)
	re:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	re:GetHandler():ResetFlagEffect(id)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(s.distarget)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE)
	Duel.RegisterEffect(e1,tp)
end
function s.distarget(e,c)
	return c~=e:GetHandler() and c:IsSpellTrap() and c:GetFlagEffect(id)>0
end