--ダイナ・ボディ・ヒート
--Dyna Body Heat
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--Cannot be destroyed by the opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--Cannot be returned to the hand or Deck
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CANNOT_TO_DECK)
	e4:SetCondition(s.indcond)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e5)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end
function s.eftg(e,c)
	return e:GetHandler():GetEquipTarget()==c
end
function s.indcond(e)
	return Duel.IsTurnPlayer(1-e:GetHandlerPlayer())
end