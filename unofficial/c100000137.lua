--ハッピー・マリッジ
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,nil,nil,nil,nil,nil,s.con)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.value)
	c:RegisterEffect(e3)
end
function s.filter(c,tp)
	return c:GetOwner()==1-tp and c:IsFaceup()
end
function s.con(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function s.value(e,c)
	local wup=0
	local wg=Duel.GetMatchingGroup(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil,e:GetHandlerPlayer())
	local wbc=wg:GetFirst()
	while wbc do
		wup=wup+wbc:GetAttack()
		wbc=wg:GetNext()
	end
	return wup
end
