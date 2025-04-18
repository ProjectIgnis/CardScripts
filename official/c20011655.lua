--魔剣達士－タルワール・デーモン
--Beast of Talwar - The Sword Summit
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If you control no monsters, you can Special Summon this card (from your hand)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--The first time this card would be destroyed by an opponent's card effect each turn, it is not destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetValue(function(e,re,r,rp) return (r&REASON_EFFECT)>0 and rp==1-e:GetHandlerPlayer() end)
	c:RegisterEffect(e2)
	--Neither player can target other monsters with Equip Spell Cards or effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(function(e,c) return c~=e:GetHandler() and c:IsMonster() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) end)
	e3:SetValue(s.tgval)
	c:RegisterEffect(e3)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.tgval(e,re,rp)
	if not (re:IsSpellEffect() and re:IsActiveType(TYPE_EQUIP)) then return false end
	local typ,eff=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_TYPE,CHAININFO_TRIGGERING_EFFECT)
	if eff==re then
		return typ&(TYPE_SPELL|TYPE_EQUIP)==TYPE_SPELL|TYPE_EQUIP
	else
		return re:GetHandler():IsEquipSpell()
	end
end