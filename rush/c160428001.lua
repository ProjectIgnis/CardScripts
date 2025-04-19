--超魔輝獣マグナム・オーバーロード［Ｌ］
--Supreme Wildgleam Magnum Overlord [L]
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.maxCon)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(s.pcon)
	c:RegisterEffect(e2)
	c:AddSideMaximumHandler(e2)
end
s.MaximumSide="Left"
function s.maxCon(e)
	--maximum mode check to do
	return e:GetHandler():IsMaximumMode()
end
function s.val(e,c)
	return Duel.GetFieldGroupCountRush(c:GetControler(),0,LOCATION_MZONE)*500
end
function s.pcon(e)
	return e:GetHandler():IsMaximumMode() and Duel.GetMatchingGroupCount(Card.IsMonster,e:GetHandler():GetControler(),LOCATION_GRAVE,0,nil)>=10
end