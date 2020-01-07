--Performapal Card Gardna
local s,id=GetID()
function s.initial_effect(c)
	--defup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	
end
function s.exfilter(c)
	return c:IsFaceup() and c:IsCode(id)
end
function s.val(e,c)
	local def=0
	local g=Duel.GetMatchingGroup(s.filter,c:GetControler(),LOCATION_MZONE,0,c)
	local tc=g:GetFirst()
	while tc do
		local cdef=tc:GetDefense()
		def=def+(cdef>=0 and cdef or 0)
		tc=g:GetNext()
	end
	return def
end
