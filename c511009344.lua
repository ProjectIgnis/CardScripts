--Parasite Queen
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,6205579,aux.FilterBoolFunctionEx(Card.IsType,TYPE_FUSION))
	-- atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--atkdown
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--return to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80344569,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.eqcon)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
end
s.listed_names={6205579}
s.material_setcode=0x53d
function s.val(e,c)
	local val1=Duel.GetMatchingGroupCount(s.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local val2=Duel.GetMatchingGroupCount(s.filter2,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	return (val1+val2)*300
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(6205579)
end
function s.filter2(c)
	return c:IsFaceup() and c:IsCode(6205579) and c:IsHasEffect(511009347)
end
function s.atktg(e,c)
	return not c:IsCode(id)
end
function s.atkval(e,c)
	local val1=c:GetEquipGroup():FilterCount(s.filter,nil)
	local val2=c:GetEquipGroup():FilterCount(s.filter2,nil)
	return (val1+val2)*-800
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and e:GetHandler():GetEquipGroup():IsExists(Card.IsCode,1,nil,6205579)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local eqc=e:GetHandler():GetEquipGroup():FilterSelect(tp,Card.IsCode,1,1,nil,6205579):GetFirst()
	if eqc and tc:IsFaceup() and tc:IsRelateToBattle() then
		if not Duel.Equip(tp,eqc,tc,false) then return end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		eqc:RegisterEffect(e1)
	end
end
function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end
