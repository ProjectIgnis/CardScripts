--ジェスター・ロード
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
end
function s.atkcon(e)
	return not Duel.IsExistingMatchingCard(nil,0,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
function s.filter(c)
	return c:GetSequence()<5
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.filter,0,LOCATION_SZONE,LOCATION_SZONE,nil)*1000
end
