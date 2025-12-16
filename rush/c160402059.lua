--トロイホース
--The Trojan Horse
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--double tribute
	c:AddDoubleTribute(id,s.otfilter,s.eftg,0,FLAG_DOUBLE_TRIB_LEVEL7+FLAG_DOUBLE_TRIB_LEVEL8+FLAG_DOUBLE_TRIB_EARTH)
end
function s.otfilter(c,tp)
	return c:IsDoubleTribute(FLAG_DOUBLE_TRIB_LEVEL7+FLAG_DOUBLE_TRIB_LEVEL8+FLAG_DOUBLE_TRIB_EARTH) and (c:IsControler(tp) or c:IsFaceup())
end
function s.eftg(e,c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevel(7,8) and c:IsSummonableCard()
end
