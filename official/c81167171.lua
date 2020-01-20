--ヒーロースピリッツ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]=false
		s[1]=false
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYED)
		ge1:SetOperation(s.checkop1)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s[0]=false
			s[1]=false
		end)
	end)
end
function s.checkop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		if tc:IsPreviousSetCard(0x3008) then
			s[tc:GetPreviousControler()]=true
		end
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return s[tp] and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE_CAL)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(1)
	e2:SetReset(RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE_CAL)
	Duel.RegisterEffect(e2,tp)
end
