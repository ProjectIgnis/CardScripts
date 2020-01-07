--機関連結
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),nil,s.cost)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	--double original atk
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_ADJUST)
	e5:SetRange(LOCATION_SZONE)
	e5:SetOperation(s.atkop)
	e5:SetLabel(0)
	c:RegisterEffect(e5)
	--check for doubling
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(511000694)
	c:RegisterEffect(e6)
end
function s.costfilter(c)
	return c:IsRace(RACE_MACHINE) and c:GetLevel()>=8 and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.filterchk(c,g,sg)
	sg:AddCard(c)
	local res
	if #sg<2 then
		res=g:IsExists(s.filterchk,1,sg,g,sg)
	else
		res=Duel.IsExistingTarget(function(c) return c:IsFaceup() and c:IsRace(RACE_MACHINE) end,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	sg:RemoveCard(c)
	return res
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return g:IsExists(s.filterchk,1,nil,g,Group.CreateGroup()) end
	local rg=Group.CreateGroup()
	while #rg<2 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:FilterSelect(tp,s.filterchk,1,1,rg,g,rg)
		rg:Merge(sg)
	end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.chkfilter(c,eq)
	local ec=c:GetEquipTarget()
	return c:IsHasEffect(511000694) and ec and ec==eq and not c:IsDisabled()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local eq=c:GetEquipTarget()
	local g=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_SZONE,LOCATION_SZONE,c,eq)
	if eq and c:GetFlagEffect(511000695)==0 and e:GetLabel()~=#g+1 then
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
		local tc=g:GetFirst()
		while tc do
			tc:RegisterFlagEffect(511000695,RESET_EVENT+RESETS_STANDARD_DISABLE,0,0)
			tc=g:GetNext()
		end
		local atk=eq:GetBaseAttack()
		for i=1,#g+1 do
			atk=atk*2
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		e:SetLabel(#g+1)
	end
end
