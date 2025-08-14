--電池メン－単三型
--Batteryman AA
local s,id=GetID()
function s.initial_effect(c)
	--If all "Batteryman AA"(s) on your side of the field are in Attack Position, this card gains 1000 ATK for each "Batteryman AA" on your side of the field
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetCondition(s.atkdefcon(Card.IsAttackPos))
	e1a:SetValue(function(e,c) return 1000*Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsCode,id),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil) end)
	c:RegisterEffect(e1a)
	--If all "Batteryman AA"(s) on your side of the field are in Defense Position, this card gains 1000 DEF for each "Batteryman AA" on your side of the field
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	e1b:SetCondition(s.atkdefcon(Card.IsDefensePos))
	c:RegisterEffect(e1b)
end
s.listed_names={id}
function s.atkdefcon(pos_function)
	return function(e,c)
			local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,id),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
			return #g>0 and g:FilterCount(pos_function,nil)==#g
	end
end