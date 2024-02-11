--ハーピィズフルドレス
--Harpie's Full Dress
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--Increase ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(400)
	c:RegisterEffect(e2)
	--Pierce
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_HARPIE_LADY,160208002} --Harpie Ladies
function s.eqfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_HARPIE_LADY,160208002) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.eftg(e,c)
	return e:GetHandler():GetEquipTarget()==c
end
function s.condition(e)
	local ct=Duel.GetMatchingGroupCountRush(aux.FaceupFilter(Card.IsMonster),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return ct==1 or ct==3
end