--電池メン－単二型
--Batteryman C
local s,id=GetID()
function s.initial_effect(c)
	--If all "Batteryman C"(s) you control are in Attack Position, all Machine-Type monsters you control gain 500 ATK for each "Batteryman C" you control
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetTargetRange(LOCATION_MZONE,0)
	e1a:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_MACHINE))
	e1a:SetCondition(s.atkdefcon(Card.IsAttackPos))
	e1a:SetValue(function(e,c) return 500*Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsCode,id),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil) end)
	c:RegisterEffect(e1a)
	--If all "Batteryman C"(s) you control are in Defense Position, all Machine-Type monsters you control gain 500 DEF for each "Batteryman C" you control
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