--Grit
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.roll_dice=true
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.HasFlagEffect(ep,id) and Duel.IsTurnPlayer(tp) and Duel.GetCurrentChain()==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	local n1=Duel.AnnounceLevel(tp,1,6)
	local n2=Duel.AnnounceLevel(tp,1,6,n1)
	local dc=Duel.TossDice(tp,1)
	if n1==dc or n2==dc then
		local c=e:GetHandler()
		--If you roll a number you called, your LP do not get lower than 1 until the end of your opponent's next turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_LOSE_LP)
		e1:SetTargetRange(1,0)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_ADJUST)
		e2:SetOperation(function(e,tp)
					if Duel.GetLP(tp)<1 then
						Duel.SetLP(tp,1)
					end
				end)
		e2:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN)
		Duel.RegisterEffect(e2,tp)
	end
end
