--ユニオン・ドライバー
--Union Driver
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	aux.AddUnionProcedure(c)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	e:SetLabelObject(c:GetEquipTarget())
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.filter(c,ec,ign_ct)
	return c:IsLevelBelow(4) and c:IsType(TYPE_UNION) and c:CheckEquipTarget(ec) and aux.CheckUnionEquip(c,ec,ign_ct)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local ec=e:GetHandler():GetEquipTarget()
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 and ec
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,ec,1) 
	end
	e:GetLabelObject():CreateEffectRelation(e)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tc,0)
		local ec=sg:GetFirst()
		if ec and aux.CheckUnionEquip(ec,tc) and Duel.Equip(tp,ec,tc) then
			aux.SetUnionState(ec)
		end
	end
end

