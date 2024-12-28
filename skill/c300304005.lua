--Cyber Blade Fusion
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_names={10248389,11460577,97023549} --"Cyber Blader", "Etoile Cyber", "Blade Skater"
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and not Duel.HasFlagEffect(tp,id,2) and s.cost(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.costfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsDiscardable() then return false end
	local params={fusfilter=aux.FilterBoolFunction(Card.IsCode,10248389),
		matfilter=Fusion.OnFieldMat,
		extrafil=s.fextra(c),
		stage2=s.stage2}
	return Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST|REASON_DISCARD,nil,e,tp,eg,ep,ev,re,r,rp)
end
function s.fextra(exc)
	return function(e,tp,mg)
		return Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_DECK,0,nil),s.fcheck(exc)
	end
end
function s.fcheckmatfilter(c,fc,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsSummonCode(fc,SUMMON_TYPE_FUSION,tp,11460577,97023549)
end
function s.fcheck(exc)
	return function(tp,sg,fc)
		return not (exc and sg:IsContains(exc)) and sg:IsExists(s.fcheckmatfilter,1,nil,fc,tp)
	end
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		--It gains 400 ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--You can only apply this effect twice per Duel
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Discard 1 card
	s.cost(e,tp,eg,ep,ev,re,r,rp,1)
	--Fusion Summon 1 "Cyber Blader"
	local params={fusfilter=aux.FilterBoolFunction(Card.IsCode,10248389),
		matfilter=Fusion.OnFieldMat,
		extrafil=s.fextra(c),
		stage2=s.stage2}
	Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
	Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
end