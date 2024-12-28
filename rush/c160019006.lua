--ダイスキー・バチカ
--Dice Key Bachika
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--cannot be tributed for a Tribute Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.etarget)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.etarget(e,c)
	return c:IsFaceup() and (c==e:GetHandler() or c:IsCode(160019005))
end
function s.indcon(e)
	return e:GetHandler():IsAttackPos()
end