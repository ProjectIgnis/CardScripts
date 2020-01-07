--Eshila the Lovely Bisque Doll
local s,id=GetID()
function s.initial_effect(c)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
function s.val(e,c)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,0x2517)
	local atk=0
	while #g>=4 and g:GetClassCount(Card.GetCode)>=4 do
		local g1=g:GetFirst()
		local g2=g:GetNext()
		while g2:GetCode()==g1:GetCode() do
			g2=g:GetNext()
		end
		local g3=g:GetNext()
		while g3:GetCode()==g1:GetCode() or g3:GetCode()==g2:GetCode() do
			g3=g:GetNext()
		end
		local g4=g:GetNext()
		while g4:GetCode()==g1:GetCode() or g4:GetCode()==g2:GetCode() or g4:GetCode()==g3:GetCode() do
			g4=g:GetNext()
		end
		if g1 and g2 and g3 and g4 then
			g:Sub(Group.FromCards(g1,g2,g3,g4))
			atk=atk+1000
		end
	end
	return atk
end
