--宝牙の儀式
--Jeweled Tusk Ritual
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup,stage2=s.stage2})
	c:RegisterEffect(e1)
end
s.listed_names={160022039}
function s.ritualfil(c)
	return c:IsCode(160022039)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_HAND)
end
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp,tc)
	local c=e:GetHandler()
	--Your opponent cannot activate Traps when it is summoned
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_END)
	e1:SetCountLimit(1)
	e1:SetOperation(function() Duel.SetChainLimitTillChainEnd(s.actlimit) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.actlimit(e,tp,p)
	return not e:GetHandler():IsType(TYPE_TRAP) or not e:GetHandler():IsControler(1-tp)
end