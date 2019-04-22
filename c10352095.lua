--幻惑の巻物
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,nil,nil,nil,s.target)
	--ATTRIBUTE
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetCondition(s.attcon)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,tc,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	local rc=Duel.AnnounceAttribute(tp,1,0xff-tc:GetAttribute())
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,rc)
	e:GetHandler():SetHint(CHINT_ATTRIBUTE,rc)
end
function s.attcon(e)
	return e:GetHandler():GetFlagEffect(id)~=0
end
function s.value(e,c)
	return e:GetHandler():GetFlagEffectLabel(id)
end
