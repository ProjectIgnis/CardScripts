--Leading Question
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.val)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(800)
	c:RegisterEffect(e2)
end
function s.val(e,c)
	local ph=Duel.GetCurrentPhase()
	if not (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) then return end
	return c:IsFaceup() and c:IsRelateToBattle() and c:GetBattleTarget()~=nil
		and c:IsLevelBelow(4) and c:IsType(TYPE_FUSION)
end