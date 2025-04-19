--機関連結 (Anime)
--Train Connection (Anime)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.eqfilter,s.eqlimit,s.cost)
	--Double the equipped monster's original ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(function(e,c) return c:GetBaseAttack()*2 end)
	c:RegisterEffect(e1)
	--Inflict piercing damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
function s.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c and c:IsRace(RACE_MACHINE)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
function s.rmfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsLevelAbove(8) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.rescon(sg,e,tp,mg)
	return Duel.IsExistingTarget(s.eqfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,sg)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end