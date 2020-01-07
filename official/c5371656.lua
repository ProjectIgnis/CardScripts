--魂喰らいの魔刀
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,0,s.filter,nil,s.cost,s.target,s.operation)
end
function s.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function s.rfilter(c)
	local tpe=c:GetType()
	return (tpe&TYPE_NORMAL)~=0 and (tpe&TYPE_TOKEN)==0 and c:IsReleasable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,tc,chk)
	local label=e:GetLabel()
	e:SetLabel(0)
	if chk==0 then return true end
	if label==1 then
		local rg=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,0,tc)
		Duel.Release(rg,REASON_COST)
		Duel.SetTargetParam(#rg*1000)
	else
		Duel.SetTargetParam(0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
