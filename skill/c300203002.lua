--Nightmare Sonic Blast!
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
end
s.listed_names={66516792}
function s.counterfilter(c)
	return not c:IsCode(66516792)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(66516792)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsAbleToHand()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	local dg=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	local fg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return aux.CanActivateSkill(tp) 
	and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
	and #dg>3 and #fg==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.ConfirmDecktop(tp,4)
	local g=Duel.GetDecktopGroup(tp,4)
	local ct=g:FilterCount(Card.IsMonster,nil)
	if ct==1 then
	--Add 1 of the revealed monsters to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:FilterSelect(tp,s.thfilter,1,1,nil)
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		g:RemoveCard(sg:GetFirst())
		Duel.ShuffleHand(tp)
		Duel.MoveToDeckBottom(g,tp)
		Duel.SortDeckbottom(tp,tp,3)
	--Destroy 1 face-up card your opponent controls
	elseif ct==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.HintSelection(dg)
		Duel.Destroy(dg,REASON_EFFECT)
		Duel.MoveToDeckBottom(g,tp)
		Duel.SortDeckbottom(tp,tp,4)
	--Apply both effects in sequence
	else
		--Add 1 revealed monster
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:FilterSelect(tp,s.thfilter,1,1,nil)
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		g:RemoveCard(sg:GetFirst())
		Duel.ShuffleHand(tp)
		--Destroy 1 face-up card your controls
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.HintSelection(dg)
		Duel.Destroy(dg,REASON_EFFECT)
		Duel.MoveToDeckBottom(g,tp)
		Duel.SortDeckbottom(tp,tp,3)
	end
	--Cannot Summon/Set monsters, except "Serpent Night Dragon"
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsCode(66516792) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e4,tp)
end