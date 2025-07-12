--Ｎｏ．３９ 希望皇ホープ (Anime)
--Number 39: Utopia (Anime)
Duel.LoadCardScript("c84013237.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2)
	--Cannot be destroyed by battle, except with "Number" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e1)
	--Negate the attack of 1 monster on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return Duel.GetAttacker() and not e:GetHandler():IsStatus(STATUS_CHAINING) end)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateAttack() end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NUMBER}
s.xyz_number=39
