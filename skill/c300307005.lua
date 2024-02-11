--Intel from the "Cosmos"
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	 --Opponent must reveal all cards drawn during their Draw Phase
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(0x5f)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.rvcon)
	e1:SetOperation(s.rvop)
	Duel.RegisterEffect(e1,tp)
end
function s.rvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsPhase(PHASE_DRAW) and #eg>0
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
	local hg=eg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if #hg>0 then
		Duel.ConfirmCards(tp,hg)
	end
end