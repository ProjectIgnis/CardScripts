--Ｒ・ライセンス
--Rising License
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Rising Equip" in the Graveyard
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(160025062)
	c:RegisterEffect(e0)
	--Activate
	Fusion.RegisterSummonEff(c,s.fusfilter,s.matfilter)
end
function s.fusfilter(c)
	return c:ListsCodeAsMaterial(160025042,160025026)
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_HAND|LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGrave()
end