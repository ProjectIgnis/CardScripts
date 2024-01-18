--Slimey Disposition
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={46821314,73216412,5600127}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition for the first effect:
	local b1=Duel.GetFlagEffect(tp,id)==0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	--condition for the second effect:
	local params={fusfilter=s.fusmonfilter,
					matfilter=Fusion.OnFieldMat,
					extrafil=s.extrafusmat,
					extratg=s.extratarget}
	local b2=Duel.GetFlagEffect(tp,id+100)==0 and Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
--Special Summon Function
function s.spfilter(c,e,tp)
	return c:IsCode(46821314,73216412) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
--Fusion Summon functions
function s.fusmonfilter(c)
	return c:IsCode(5600127)
end
function s.specialcheck(tp,sg,fc)
	return sg:GetClassCount(Card.GetLocation,nil)==#sg
end
function s.extrafusmat(e,tp,mg)
	return Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_DECK,0,nil),s.specialcheck
end
function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--For the Special Summon
	local b1=Duel.GetFlagEffect(tp,id)==0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	--For the Fusion Summon
	local params={fusfilter=s.fusmonfilter,
					matfilter=Fusion.OnFieldMat,
					extrafil=s.extrafusmat,
					extratg=s.extratarget}
	local b2=Duel.GetFlagEffect(tp,id+100)==0 and Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
	local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,0)},
			{b2,aux.Stringid(id,1)})
	if op==1 then
		--OPT Register (Special Summon from GY)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		--Special Summon "Humanoid Slime" or "Worm Drake" from GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if sc then
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3303)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			e1:SetValue(1)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UNRELEASABLE_SUM)
			e2:SetValue(function(e,c) return not c:IsRace(RACE_DIVINE) end)
			sc:RegisterEffect(e2)
		end
	else
		--Fusion Summon "Humanoid Worm Drake"
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
		--OPT Register (Fusion Summon)
		Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp,1)
	end
end