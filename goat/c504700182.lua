--鉄の騎士 ギア・フリード
--Gearfried the Iron Knight (GOAT)
--effect is continuous
local s,id=GetID()
function s.initial_effect(c)
	--destroy equip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_EQUIP)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.filter(c,ec)
	return c:GetEquipTarget()==ec
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.filter,1,nil,e:GetHandler()) end
	local dg=eg:Filter(s.filter,nil,e:GetHandler())
	e:SetLabelObject(dg)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetLabelObject()
	Duel.Destroy(tg,REASON_EFFECT)
end
