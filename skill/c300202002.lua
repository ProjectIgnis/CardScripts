-- Beatdown!
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)	
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opt check
	if Duel.GetFlagEffect(ep,id)==0 then return end
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
	and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsLevelAbove,5),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,0,id|(1<<32))
	Duel.Hint(HINT_CARD,0,id)
	--opt register
	Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,0)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local atk=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsLevelAbove,5),tp,LOCATION_MZONE,0,nil)*200
	if #g==0 or atk==0 then return end
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
	end
		--flip during End phase
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetOperation(s.EPop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
end
function s.EPop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,0,id|(2<<32))
end
