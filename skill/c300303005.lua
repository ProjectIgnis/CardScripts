--The Psychic Duelist
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	local c=e:GetHandler()
	local b1=Duel.GetFlagEffect(ep,id)==0 and Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_SZONE,1,nil,POS_FACEDOWN)
	local b2=Duel.GetFlagEffect(ep,id+1)==0 and Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_HAND,1,nil)
	--condition
	return aux.CanActivateSkill(tp) and (b1 or b2) and Duel.GetTurnPlayer()==tp and Duel.IsMainPhase()
end
function s.cfilter(c)
	return not c:IsPublic()
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	local b1=Duel.GetFlagEffect(ep,id)==0 and Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_SZONE,1,nil,POS_FACEDOWN)
	local b2=Duel.GetFlagEffect(ep,id+1)==0 and Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_HAND,1,nil)
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	end
	if not (b1 or b2) then return false end
	if (b1 and op==0) or Duel.GetFlagEffect(ep,id+1)>0 then
			Duel.RegisterFlagEffect(ep,id,0,0,0)
			Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
			local stg=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_SZONE,nil)
			local tc=stg:Select(tp,1,1,nil):GetFirst()
			local opt=Duel.SelectOption(tp,70,71,72)
			Duel.ConfirmCards(tp,tc)
			if (opt==0 and tc:IsOriginalType(TYPE_MONSTER) or (opt==1 and tc:IsOriginalType(TYPE_SPELL)) or (opt==2 and tc:IsOriginalType(TYPE_TRAP))) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				e1:SetValue(1)
				tc:RegisterEffect(e1)
			end	   
	 elseif b2 and op==1 or Duel.GetFlagEffect(ep,id)>0 then
			Duel.RegisterFlagEffect(ep,id+1,0,0,0)
			Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
			local hg=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_HAND,nil)
			local rand=hg:RandomSelect(tp,1):GetFirst()
			local opt=Duel.SelectOption(tp,70,71,72)
			Duel.ConfirmCards(tp,rand)
			if (opt==0 and rand:IsOriginalType(TYPE_MONSTER) or (opt==1 and rand:IsOriginalType(TYPE_SPELL)) or (opt==2 and rand:IsOriginalType(TYPE_TRAP))) then
				Duel.Damage(1-tp,500,REASON_EFFECT)
			end
	end
end