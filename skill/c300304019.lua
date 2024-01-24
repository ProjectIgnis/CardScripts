--I've Got Dino DNA!
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Gain 200 LP during each Draw Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_DRAW)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
	e1:SetOperation(s.recop)
	Duel.RegisterEffect(e1,tp)
	--Place on deckbottom and draw if normal draw was Dinosaur monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DRAW)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCountLimit(1)
	e2:SetRange(0x5f)
	e2:SetCondition(s.drcon)
	e2:SetOperation(s.drop)
	Duel.RegisterEffect(e2,tp)
	--Make 1 Dinosaur monster gain 200 ATK until the end of the turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(0x5f)
	e3:SetCountLimit(1)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	Duel.RegisterEffect(e3,tp)
end
--Recovery operation
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Recover(tp,200,REASON_EFFECT)
end
--Draw Functions
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return Duel.GetCurrentPhase()==PHASE_DRAW and Duel.IsTurnPlayer(tp) and ec:IsReason(REASON_RULE) and ec:IsRace(RACE_DINOSAUR) and ec:IsAbleToDeck()
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.ConfirmCards(1-tp,tc)
		if Duel.SendtoDeck(tc,tp,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
--ATK gain functions
function s.atkcon(e)
	local tp=e:GetHandlerPlayer()
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_DINOSAUR),tp,LOCATION_MZONE,0,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local tc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsRace,RACE_DINOSAUR),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(200)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	tc:RegisterEffect(e1)
end