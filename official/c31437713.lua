--Ｎｏ．８２ ハートランドラコ
--Number 82: Heartlandraco
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2)
	--While you control a face-up Spell, your opponent cannot target this card for attacks
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSpell),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil) end)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	--Apply a "this turn, this card can attack your opponent directly, but other monsters cannot attack" effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e) return Duel.IsAbleToEnterBP() and not e:GetHandler():IsHasEffect(EFFECT_DIRECT_ATTACK) end)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.xyz_number=82
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local fid=-1
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		fid=c:GetFieldID()
		--This turn, this card can attack your opponent directly
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3205)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1))
	--But other monsters cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:GetFieldID()~=fid end)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
