--セレブラウス・デスワンショルダー
--Celeb Blouse - Death One Shoulder
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--Name becomes "Charis Magic Scepter - Death Wand" in the Graveyard
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetValue(160013053)
	c:RegisterEffect(e1)
	--Change name of equipped monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(160013010)
	e2:SetOperation(s.chngcon)
	c:RegisterEffect(e2)
	--Cannot be returned to the hand or Deck
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_TO_DECK)
	e3:SetCondition(s.indcond)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e4)
end
function s.eqfilter(c)
	return c:IsFaceup() and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.chngcon(scard,sumtype,tp)
	return (sumtype&MATERIAL_FUSION)~=0 or (sumtype&SUMMON_TYPE_FUSION)~=0
end
function s.indcond(e)
	return Duel.IsTurnPlayer(1-e:GetHandlerPlayer())
end