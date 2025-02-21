--進化の宿命
--Evo-Karma
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Your opponent cannot activate cards and effect when a monster is summoned by the effect of an "Evoltile" monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.sumlimop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(s.chainendop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.sumlimop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsEvoltileSummoned,1,nil) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.chainendop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) and e:GetLabelObject():GetLabel()==1 then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
end