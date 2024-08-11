--Ancient Fusion
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_series={SET_ANCIENT_GEAR}
s.listed_names={CARD_ANCIENT_GEAR_GOLEM}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and s.cost(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id)
end
function s.costfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsDiscardable() then return false end
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_ANCIENT_GEAR),
		matfilter=Fusion.OnFieldMat,
		extrafil=s.fextra(c),
		stage2=s.stage2}
	return Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST|REASON_DISCARD,nil,e,tp,eg,ep,ev,re,r,rp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.fcheckmatfilter(c)
	return c:IsCode(83104731,95735217,7171149,12652643) and c:IsFaceup() and c:IsOnField()
end
function s.fextra(exc)
	return function(e,tp,mg)
		if mg:IsExists(s.fcheckmatfilter,1,nil) then
			local eg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_HAND|LOCATION_DECK,0,nil)
			if eg and #eg>0 then
				return eg,s.fcheck(exc)
			end
		end
	end
end
function s.fcheck(exc)
	return function(tp,sg,fc)
		if sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND|LOCATION_DECK) then
			return sg:IsExists(s.fcheckmatfilter,1,nil) end
		return not (exc and sg:IsContains(exc)) 
	end
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		--Halve all battle damage this card inflicts to your opponent
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e1:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Your opponent takes no damage for the rest of this turn
	local ge1=Effect.CreateEffect(e:GetHandler())
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetCode(EFFECT_CHANGE_DAMAGE)
	ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ge1:SetTargetRange(0,1)
	ge1:SetValue(0)
	ge1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(ge1,tp)
	local ge2=ge1:Clone()
	ge2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	ge2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(ge2,tp)
	--You can only apply this effect once per Duel
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Discard 1 card
	s.cost(e,tp,eg,ep,ev,re,r,rp,1)
	--Fusion Summon 1 "Ancient Gear" Fusion monster
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_ANCIENT_GEAR),
		matfilter=Fusion.OnFieldMat,
		extrafil=s.fextra(c),
		stage2=s.stage2}
	Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
	Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)	
end
