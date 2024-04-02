--ルミナス・シャーマン
--Shining Shaman
local s,id=GetID()
function s.initial_effect(c)
	--Let a level 4 or lower spellcaster attack directly
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
--Check if this card can be sent to GY
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
end
--Check for level 4 or lower spellcaster
function s.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_SPELLCASTER) and c:CanAttack() and c:IsNotMaximumModeSide()
end
--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
end
--Send this card to the GY to let a level 4 or lower spellcaster attack directly
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler()):GetFirst()
	Duel.HintSelection(tc)
	if tc and tc:IsFaceup() then
		--Can attack directly
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3205)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end