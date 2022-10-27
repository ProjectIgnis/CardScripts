--Rule of the day "Trick & Treat"
--[[When either player draws for their normal draw send the top card of their deck to the graveyard]]
local s,id=GetID()
function s.initial_effect(c)
	aux.GlobalCheck(s,function()
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_STARTUP)
		e1:SetOperation(s.activate)
		Duel.RegisterEffect(e1,0)
	end)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	Duel.RegisterEffect(e1,0)
	local e2=e1:Clone()
	Duel.RegisterEffect(e2,1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetDrawCount(tp)>0 and Duel.IsTurnPlayer(tp) and r==REASON_RULE and Duel.GetCurrentPhase()==PHASE_DRAW 
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,1,REASON_RULE)
end
