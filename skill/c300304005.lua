--Cyber Blade Fusion
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_names={10248389,11460577,97023549}
--Fusion Summon Functions
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(ep,id)<2 and s.fusTarget(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Pre-Fusion check
	local g1=s.fusTarget(e,tp,eg,ep,ev,re,r,rp,0)
	--TPD Register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Fusion Summon "Cyber Blader" using either "Etoile Cyber" or "Blade Skater" from field and the other from hand, Deck or GY
	s.fusTarget(e,tp,eg,ep,ev,re,r,rp,1)
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK,0,nil)
	Duel.SetFusionMaterial(mg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	local fmat=Group.CreateGroup()
	if tc then
		mg:Match(s.matfilter,tc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local sc1=mg:FilterSelect(tp,Card.IsLocation,1,1,nil,LOCATION_MZONE):GetFirst()
		if sc1 then 
			fmat:AddCard(sc1)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
			local sc2=mg:FilterSelect(tp,s.mfilter,1,1,nil,sc1:GetCode()):GetFirst()
			fmat:AddCard(sc2)
		end
	end
	tc:SetMaterial(fmat)
	Duel.SendtoGrave(fmat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,true,POS_FACEUP)
	tc:CompleteProcedure()
	--That "Cyber Blader" gains 400 ATK
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(400)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
end
function s.fusDiscardFilter(c,e,tp)
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,c,e,tp)
end
function s.fusfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,true) and c:IsCode(10248389) 
end
function s.fusTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK,0,nil)
	Duel.SetFusionMaterial(mg)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.fusDiscardFilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.DiscardHand(tp,s.fusDiscardFilter,1,1,REASON_COST+REASON_DISCARD,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.mfilter(c,code)
	return c:IsCanBeFusionMaterial() and c:IsLocation(LOCATION_DECK+LOCATION_HAND+LOCATION_MZONE) and not c:IsCode(code)
end
function s.matfilter(c)
	return (c:IsCode(11460577) or c:IsCode(97023549)) and c:IsCanBeFusionMaterial()
end