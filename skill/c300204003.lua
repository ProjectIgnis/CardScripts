--Thousand-Eyes Spell
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={64631466,63519819} --"Relinquished", "Thousand-Eyes Restrict"
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and not Duel.HasFlagEffect(tp,id) and s.cost(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.costfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsDiscardable() then return false end
	local rit_params={filter=function(ritual_c) return ritual_c:IsCode(64631466) and ritual_c~=c end,lvtype=RITPROC_GREATER,forcedselection=s.rcheck(c)}
	local fus_params={fusfilter=aux.FilterBoolFunction(Card.IsCode,63519819),extrafil=s.fextra(c)}
	return Ritual.Target(rit_params)(e,tp,eg,ep,ev,re,r,rp,0)
		or Fusion.SummonEffTG(fus_params)(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST|REASON_DISCARD,nil,e,tp,eg,ep,ev,re,r,rp)
end
function s.fextra(exc)
	return function(e,tp,mg)
		return nil,s.fcheck(exc)
	end
end
function s.fcheck(exc)
	return function(tp,sg,fc)
		return not (exc and sg:IsContains(exc))
	end
end
function s.rcheck(exc)
	return function(e,tp,sg,rc)
		return not (exc and sg:IsContains(exc))
	end
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Soft OPT
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	--Discard 1 card
	s.cost(e,tp,eg,ep,ev,re,r,rp,1)
	local rit_params={filter=aux.FilterBoolFunction(Card.IsCode,64631466),lvtype=RITPROC_GREATER,forcedselection=s.rcheck(c)}
	local fus_params={fusfilter=aux.FilterBoolFunction(Card.IsCode,63519819),extrafil=s.fextra(c)}
	local b1=Ritual.Target(rit_params)(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=Fusion.SummonEffTG(fus_params)(e,tp,eg,ep,ev,re,r,rp,0)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if op==1 then
		--Ritual Summon 1 "Relinquished" from your hand by Tributing a monster from your hand or field whose Level is 1 or more, also flip this card over
		Ritual.Target(rit_params)(e,tp,eg,ep,ev,re,r,rp,1)
		Ritual.Operation(rit_params)(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		--Fusion Summon 1 "Thousand-Eyes Restrict" from your Extra Deck, using monsters from your hand or field as Fusion Material, also flip this card over
		Fusion.SummonEffTG(fus_params)(e,tp,eg,ep,ev,re,r,rp,1)
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
	end
	--You cannot conduct your Battle Phase this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Flip this card over
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
end
