--焔魔神ベルシュドロス［Ｌ］
--Blaze Fiend Overlords Beelucitaroth [L]
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.maxCon)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
end
s.MaximumSide="Left"
function s.maxCon(e)
	return e:GetHandler():IsMaximumMode()
end
function s.val(e,c)
	return c:IsType(TYPE_NORMAL)
end