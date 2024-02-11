--ハーピィズペット竜
--Harpie's Pet Dragon (Rush)
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_HARPIE_LADY}
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil,CARD_HARPIE_LADY)*300
		+ Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil,160208002)*900
end
function s.filter(c,code)
	return c:IsFaceup() and c:IsCode(code) and not c:IsMaximumModeSide()
end

