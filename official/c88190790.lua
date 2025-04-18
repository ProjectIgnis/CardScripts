--アサルト・アーマー
--Assault Armor
local s,id=GetID()
function s.initial_effect(c)
	--Equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--Atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--Can make a second attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.macon)
	e2:SetCost(s.macost)
	e2:SetOperation(s.maop)
	c:RegisterEffect(e2)
end
function s.eqlimit(e,c)
	if e:GetHandler():GetEquipTarget()==c then return true end
	local g=Duel.GetFieldGroup(e:GetHandlerPlayer(),LOCATION_MZONE,0)
	return c:IsRace(RACE_WARRIOR) and #g==1 and g:GetFirst()==c
end
function s.eqfilter(c,e,tp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return c:IsRace(RACE_WARRIOR) and #g==1 and g:GetFirst()==c
end
function s.macon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.macost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SetTargetCard(c:GetEquipTarget())
	Duel.SendtoGrave(c,REASON_COST)
end
function s.maop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end