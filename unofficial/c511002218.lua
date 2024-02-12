--薔薇の盾
--Rose Shield
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,nil,nil,nil,s.tg,s.op)
	--Destruction replacement for the equipped monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,tc)
	e:SetCategory(CATEGORY_EQUIP+CATEGORY_DAMAGE)
	e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	Duel.SetTargetParam(ct*300)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		Duel.Damage(p,ct*300,REASON_EFFECT)
	end
end