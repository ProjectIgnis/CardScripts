--ホーリーフレーム
--Light Effigy (Rush)
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--double tribute
	c:AddDoubleTribute(id,s.otfilter,s.eftg,0,FLAG_DOUBLE_TRIB_LIGHT+FLAG_DOUBLE_TRIB_NORMAL)
end
function s.otfilter(c,tp)
	return c:IsDoubleTribute(FLAG_DOUBLE_TRIB_LIGHT+FLAG_DOUBLE_TRIB_NORMAL) and (c:IsControler(tp) or c:IsFaceup())
end
function s.eftg(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_NORMAL) and c:IsLevelAbove(7) and c:IsSummonableCard()
end
