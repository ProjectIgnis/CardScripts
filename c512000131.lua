--だがダメージは受け手貰う！
--But You Still Take The Damage!
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --indes
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    --double damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DoubleBattleDamage(ep)
end