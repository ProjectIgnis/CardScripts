--エクゾディア・ネクロス(Anime)
--Exodia Necross (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--"Exodia the Forbidden One": This card cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.battlecon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--"Left Leg of the Forbidden One": This card cannot be destroyed by Spell Cards.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.spellcon)
	e3:SetValue(s.spellval)
	c:RegisterEffect(e3)
	--"Right Leg of the Forbidden One": This card cannot be destroyed by Trap Cards.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.trapcon)
	e4:SetValue(s.trapval)
	c:RegisterEffect(e4)
	--"Left Arm of the Forbidden One": This card cannot be destroyed by the effects of other Effect Monsters.
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.monstercon)
	e5:SetValue(s.monsterval)
	c:RegisterEffect(e5)
	--"Right Arm of the Forbidden One": Each time this card battles, it gains 1000 ATK at the end of the Damage Step.
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_DAMAGE_STEP_END)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.atkcon)
	e6:SetOperation(s.atkop)
	c:RegisterEffect(e6)
	--Revert ATK changes if removed from field/if no Right Arm in GY
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetValue(s.atkval)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_MOVE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetOperation(s.resetatk)
	c:RegisterEffect(e8)
end
s.listed_names={33396948,44519536,8124921,7902349,70903634}
function s.battlecon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,33396948)
end
function s.spellcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,44519536)
end
function s.spellval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL)
end
function s.trapcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,8124921)
end
function s.trapval(e,re,rp)
	return re:IsActiveType(TYPE_TRAP)
end
function s.monstercon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,7902349)
end
function s.monsterval(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,70903634)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD_DISABLE,0,1)
	end
end
function s.atkval(e,c)
	return e:GetHandler():GetFlagEffect(id)*1000
end
function s.resetatk(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,70903634) then return end
	local c=e:GetHandler()
	if c:GetFlagEffect(id)>0 then
		c:ResetFlagEffect(id)
	end
end