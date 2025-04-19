--手をつなぐ魔人 (Anime)
--Hand-Holding Genie (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,c:Alias())
	--atk limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)
	--defup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetCondition(s.defcon)
	e2:SetValue(s.defval)
	c:RegisterEffect(e2)
end
s.listed_names={94535485}
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
function s.defcon(e)
	return e:GetHandler():IsDefensePos()
end
function s.defval(e,c)
	return Duel.GetMatchingGroup(Card.IsFaceup,c:GetControler(),LOCATION_MZONE,0,c):GetSum(Card.GetDefense)
end