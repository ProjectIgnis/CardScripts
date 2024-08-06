--Cyber Blade Fusion
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_names={10248389,11460577,97023549}
--Skill condition
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local params={fusfilter=s.fusmonfilter,
		matfilter=Fusion.OnFieldMat,
		extrafil=s.extrafusmat,
		extratg=s.extratarget,
		stage2=s.stage2}
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)<2 and Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
end
--Fusion Summon functions
function s.fusmonfilter(c)
	return c:IsCode(10248389)
end
function s.extrafusmat(e,tp,mg)
	return Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_DECK,0,nil),s.specialcheck
end
function s.specialcheck(tp,sg,fc)
	return sg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
end
function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
--Fusion Summon operation
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local params={fusfilter=s.fusmonfilter,
		matfilter=Fusion.OnFieldMat,
		extrafil=s.extrafusmat,
		extratg=s.extratarget,
		stage2=s.stage2}
	if Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0) then
		--TPD Register
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		--Fusion Summon "Cyber Blader" using either "Etoile Cyber" or "Blade Skater" from field and the other from hand, Deck or GY
		Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
        	Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp,1)
	end
end

