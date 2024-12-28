--真紅眼の極炎竜［Ｌ］
--Red-Eyes Maxi-Flare Dragon [L]
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3001)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.maxCon)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	c:AddSideMaximumHandler(e2)
end
s.MaximumSide="Left"
function s.maxCon(e)
	return e:GetHandler():IsMaximumMode()
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsLocation(LOCATION_GRAVE) then
		Duel.Damage(1-tp,2400,REASON_EFFECT)
	end
end