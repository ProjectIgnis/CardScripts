--不運なリポート
--An Unfortunate Report
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	if Duel.IsTurnPlayer() and Duel.IsBattlePhase() then
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(s.bpcon)
		e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_OPPO_TURN,1)
	end
	Duel.RegisterEffect(e1,tp)
end
function s.bpcon(e)
	return Duel.GetTurnCount()~=e:GetLabel()
end