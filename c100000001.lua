--手をつなぐ魔人
local s,id=GetID()
function s.initial_effect(c)
	--target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)
	--defup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
end
function s.atlimit(e,c)
	return c~=e:GetHandler() and c:IsFaceup()
end
function s.val(e,c)
	local def=0
	local g=Duel.GetMatchingGroup(Card.IsPosition,c:GetControler(),LOCATION_MZONE,0,c,POS_FACEUP_DEFENSE)
	local tc=g:GetFirst()
	while tc do
		local cdef=tc:GetBaseDefense()
		def=def+(cdef>=0 and cdef or 0)
		tc=g:GetNext()
	end
	return def
end
