--セレブローブ・デスワインド
--Celeb Robe - Death Wind
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	--Cannot be destroyed by the opponent's card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--Change name when used for a Fusion Summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_ADD_CODE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(CARD_CELEB_ROSE_MAGICIAN)
	e3:SetOperation(s.chngcon)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_CELEB_ROSE_MAGICIAN}
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end
function s.chngcon(scard,sumtype,tp)
	return ((sumtype&MATERIAL_FUSION)~=0 or (sumtype&SUMMON_TYPE_FUSION)~=0) and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_CELEB_ROSE_MAGICIAN)
end