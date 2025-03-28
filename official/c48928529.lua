--Ｎｏ．８３ ギャラクシー・クィーン
--Number 83: Galaxy Queen
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Xyz summon procedure
	Xyz.AddProcedure(c,nil,1,3)
	--Your current monsters cannot be destroyed by battle, also they inflict piercing damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(Cost.Detach(1))
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
s.xyz_number=83
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		--Cannot be destroyed by battle
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3000)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END,2)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		--Inflict piercing damage
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(3208)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESETS_STANDARD_PHASE_END,2)
		tc:RegisterEffect(e2)
	end
end