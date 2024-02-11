--The Psychic Duelist
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--OPD check
	local b1=Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_SZONE,1,nil,POS_FACEDOWN)
	local b2=Duel.GetFlagEffect(tp,id+100)==0 and Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil)
	--condition
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	local b1=Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_SZONE,1,nil,POS_FACEDOWN)
	local b2=Duel.GetFlagEffect(tp,id+100)==0 and Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)})
	if not (b1 or b2) then return false end
	if (b1 and op==1) or Duel.GetFlagEffect(tp,id+100)>0 then
			Duel.RegisterFlagEffect(tp,id,0,0,0)
			Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
			local stg=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_SZONE,nil)
			local tc=stg:Select(tp,1,1,nil):GetFirst()
			local opt=Duel.SelectOption(tp,70,71,72)
			Duel.ConfirmCards(tp,tc)
			if (opt==0 and tc:IsOriginalType(TYPE_MONSTER) or (opt==1 and tc:IsOriginalType(TYPE_SPELL)) or (opt==2 and tc:IsOriginalType(TYPE_TRAP))) then
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(aux.Stringid(id,0))
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
				e1:SetValue(1)
				tc:RegisterEffect(e1)
			end	   
	 elseif (b2 and op==2) or Duel.GetFlagEffect(tp,id)>0 then
			Duel.RegisterFlagEffect(tp,id+100,0,0,0)
			Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
			local hg=Duel.GetMatchingGroup(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,nil)
			local rand=hg:RandomSelect(tp,1):GetFirst()
			local opt=Duel.SelectOption(tp,70,71,72)
			Duel.ConfirmCards(tp,rand)
			if (opt==0 and rand:IsOriginalType(TYPE_MONSTER) or (opt==1 and rand:IsOriginalType(TYPE_SPELL)) or (opt==2 and rand:IsOriginalType(TYPE_TRAP))) then
				Duel.Damage(1-tp,500,REASON_EFFECT)
			end
	end
end
