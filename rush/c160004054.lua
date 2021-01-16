--Mythic Sword Blockade
local s,id=GetID()
function s.initial_effect(c)
	--If opponent normal summons, special summon 1 Aqua monster from GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter1(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsLevelAbove(7)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.costfilter(c)
	return c:IsRace(RACE_WYRM) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.filter(c,e,tp)
	return c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.HintSelection(g)
	if #g>0 then
		--cannot attack
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD)
		ge2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		ge2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		ge2:SetTargetRange(LOCATION_MZONE,0)
		ge2:SetTarget(s.atktg)
		ge2:SetLabel(g:GetFirst():GetRace())
		ge2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(ge2,tp)
	end
end
function s.atktg(e,c)
	return c:IsRace(e:GetLabel())
end