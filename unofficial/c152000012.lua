--シークレットキュア
--Secret Cure
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_DECK,0,1,nil)
		and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated())
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--opd check and ask if you want to activate the skill or not
	if Duel.GetFlagEffect(tp,id)>0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	--opd register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Check if Skill is negated
	if aux.CheckSkillNegation(e,tp) then return end
	--LP regen/deck excavation
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_DECK,0,nil)
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local spcard=nil
	for tc in g:Iter() do
		if tc:GetSequence()>seq then
			seq=tc:GetSequence()
			spcard=tc
		end
	end
	if seq==-1 then
		Duel.ConfirmDecktop(tp,dcount)
		Duel.ShuffleDeck(tp)
		return
	end
	Duel.ConfirmDecktop(tp,dcount-seq)
	if spcard:IsAbleToHand() then
		Duel.DisableShuffleCheck()
		if dcount-seq==1 then
			Duel.SendtoHand(spcard,tp,REASON_EFFECT)
			Duel.Recover(tp,spcard:GetAttack(),REASON_EFFECT)
			Duel.Recover(1-tp,spcard:GetAttack(),REASON_EFFECT)
		else
			Duel.SendtoHand(spcard,tp,REASON_EFFECT)
			Duel.DiscardDeck(tp,dcount-seq-1,REASON_EFFECT)
			Duel.Recover(tp,spcard:GetAttack(),REASON_EFFECT)
			Duel.Recover(1-tp,spcard:GetAttack(),REASON_EFFECT)
		end
	else
		Duel.DiscardDeck(tp,dcount-seq,REASON_EFFECT)
	end
end