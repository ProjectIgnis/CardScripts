--火之迦具土
--Hino-Kagu-Tsuchi (GOAT)
--If the Draw Phase is skipped, the effect is used during the next available phase
local s,id=GetID()
function s.initial_effect(c)
	--spirit return
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--tograve
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(s.hdcon)
	e4:SetOperation(s.hdreg)
	c:RegisterEffect(e4)
end
function s.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function s.hdreg(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetReset(RESET_PHASE+PHASE_DRAW)
	local e2=e1:Clone()
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetReset(RESET_PHASE+PHASE_MAIN1)
	local e3=e1:Clone()
	e3:SetCode(EVENT_ADJUST)
	e3:SetCondition(function() return Duel.IsMainPhase() and Duel.GetTurnPlayer()==1-tp end)
	
	e1:SetOperation(s.hdop(e2,e3))
	e2:SetOperation(s.hdop(e3))
	e3:SetOperation(s.hdop())

	Duel.RegisterEffect(e1,tp)
	Duel.RegisterEffect(e2,tp)
	Duel.RegisterEffect(e3,tp)
end
function s.hdop(...)
	local effs={...}
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_DISCARD+REASON_EFFECT)
		end
		for _,eff in pairs(effs) do
			eff:Reset()
		end
		e:Reset()
	end
end
