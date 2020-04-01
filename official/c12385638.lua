--Kozmo－エピローグ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--to deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tdtg)
	e2:SetValue(LOCATION_DECKSHF)
	c:RegisterEffect(e2)
	--damage conversion
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(aux.bfgcost)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_series={0xd2}
function s.tdtg(e,c)
	return c:IsSetCard(0xd2)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_REVERSE_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.valcon)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.valcon(e,re,r,rp,rc)
	if (r&REASON_BATTLE)~=0 then
		local tp=e:GetHandlerPlayer()
		local bc=rc:GetBattleTarget()
		if bc and bc:IsSetCard(0xd2) and bc:IsControler(tp)
			and Duel.GetFlagEffect(tp,id)==0 then
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
			return true
		end
	end
	return false
end
