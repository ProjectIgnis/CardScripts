--Power Bond (Skill Card)
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and s.cost(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id)
end
function s.costfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsDiscardable() then return false end
	local params={fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),extrafil=s.fextra(c),stage2=s.stage2}
	return Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
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
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		--Gains ATK equal to its original ATK until the end of this turn
		local e1=Effect.CreateEffect(e:GetHandler())
        	e1:SetType(EFFECT_TYPE_SINGLE)
        	e1:SetCode(EFFECT_UPDATE_ATTACK)
        	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        	e1:SetValue(tc:GetBaseAttack())
        	e1:SetReset(RESETS_STANDARD_PHASE_END)
        	tc:RegisterEffect(e1,true)
        	--Cannot attack directly this turn
        	local e2=Effect.CreateEffect(e:GetHandler())
        	e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
		--You take damage equal to the gained ATK during the End Phase
        	local e3=Effect.CreateEffect(e:GetHandler())
        	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        	e3:SetCode(EVENT_PHASE+PHASE_END)
        	e3:SetCountLimit(1)
        	e3:SetLabel(tc:GetBaseAttack())
        	e3:SetReset(RESET_PHASE|PHASE_END)
        	e3:SetOperation(function(e,tp) Duel.Hint(HINT_CARD,tp,id) Duel.Damage(tp,e:GetLabel(),REASON_EFFECT) end)
        	Duel.RegisterEffect(e3,tp)
	end
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
    	Duel.Hint(HINT_CARD,tp,id)
    	local params={fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),extrafil=s.fextra(c),stage2=s.stage2}
    	--You can only apply this effect once per turn
    	Duel.RegisterFlagEffect(tp,id,0,0,0)
    	--Discard 1 card
    	s.cost(e,tp,eg,ep,ev,re,r,rp,1)
    	--Fusion Summon 1 Machine Fusion monster, using monsters from your hand or field as material
    	Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
    	Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
end
