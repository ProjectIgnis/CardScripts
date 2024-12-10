--HEROES UNITE - FUSION!!
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_series={SET_ELEMENTAL_HERO}
--Fusion Summon Functions
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and s.cost(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id)
end
function s.costfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsDiscardable() then return false end
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_ELEMENTAL_HERO),extrafil=s.fextra(c)}
	return Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST|REASON_DISCARD,nil,e,tp,eg,ep,ev,re,r,rp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
function s.fextra(exc)
	return function(e,tp,mg)
		if mg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then
			local eg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
			if eg and #eg>0 then
				return eg,s.fcheck(exc)
			end
		end
	end
end
function s.fcheck(exc)
	return function(tp,sg,fc)
		if sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
			local matg=Duel.GetFusionMaterial(tp):Filter(s.matfilter,nil,fc)
			return #matg>1 and fc.min_material_count>2 
		end
		return not (exc and sg:IsContains(exc)) 
	end
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_ELEMENTAL_HERO),extrafil=s.fextra(c)}
	--You can only apply this effect once per Duel
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Discard 1 card
	s.cost(e,tp,eg,ep,ev,re,r,rp,1)
	--Fusion Summon 1 "Elemental HERO"" Fusion monster, using monsters from your hand or field as material
	--OR use monsters from your Deck if the Fusion Monster requires 3+ materials and you control 2 "Elemental HERO" monsters listed on it as material
	Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
	Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
end
function s.matfilter(c,fc)
	return c:IsCanBeFusionMaterial(fc) and fc:ListsCodeAsMaterial(c:GetCode()) and c:IsLocation(LOCATION_MZONE)
end
