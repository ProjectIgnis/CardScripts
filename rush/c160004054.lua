--幻刃封鎖
--Mythic Sword Blockade
local s,id=GetID()
function s.initial_effect(c)
	--If opponent Normal Summons, Special Summon 1 Aqua monster from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsLevelAbove(7)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp) and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.costfilter(c)
	return c:IsRace(RACE_WYRM) and c:IsFaceup() and c:IsAbleToGraveAsCost() and not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.CanAttack),tp,0,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g=g:AddMaximumCheck()
	Duel.HintSelection(g,true)
	local ct=Duel.SendtoGrave(g,REASON_COST)
	if ct>0 then
		--Effect
		local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.CanAttack),tp,0,LOCATION_MZONE,1,1,nil)
		Duel.HintSelection(g,true)
		if #g>0 then
			--cannot attack
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetTargetRange(0,LOCATION_MZONE)
			e1:SetTarget(function(e,c) return c:IsRace(e:GetLabel()) end)
			e1:SetLabel(g:GetFirst():GetRace())
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
